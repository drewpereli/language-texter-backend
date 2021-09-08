# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Twilio", type: :request do
  describe "POST /guess" do
    subject(:post_create) { post "/twilio/guess", params: guess_params }

    let(:guess_params) do
      {"Body" => request_message}
    end

    context "when there is an active query" do
      let!(:challenge) { create(:challenge, id: 1, english_text: "foo", spanish_text: "bar", status: "complete") }
      let!(:query) { create(:query, :expecting_english_response, challenge: challenge) }
      let!(:user_drew) { create(:user, :drew) }

      before do
        allow(Rails.application.credentials).to receive(:twilio).and_return({account_ssid: 123, auth_token: "abc"})
      end

      shared_examples "it creates an attempt with the correct result status and texts drew" do |params|
        it "creates an attempt with the correct status and texts drew" do
          expect_any_instance_of(TwilioClient).to receive(:text_number).with(user_drew.phone_number,
                                                                             /\w+/).and_return(nil)
          expect { post_create }.to change(Attempt, :count).by(1)
          expect(Attempt.last.result_status).to eql(params[:expected_status])
        end
      end

      shared_examples "the challenge ends up with the correct status" do |params|
        it "ends up with the correct challenge status" do
          allow_any_instance_of(TwilioClient).to receive(:text_number).and_return(nil)
          post_create
          expect(Challenge.find(params[:challenge_id]).status).to eql(params[:expected_status])
        end
      end

      context "when it's not an already-completed challenge" do
        let!(:challenge) { create(:challenge, id: 1, english_text: "foo", spanish_text: "bar", status: "active") }
        let!(:query) { create(:query, :expecting_english_response, challenge: challenge) }

        before do
          create(:challenge, id: 2, status: "queued")
        end

        context "when the guess is incorrect" do
          let(:request_message) { "abc" }

          include_examples "it creates an attempt with the correct result status and texts drew",
                           expected_status: "incorrect_active"
          include_examples "the challenge ends up with the correct status", challenge_id: 1, expected_status: "active"
          include_examples "the challenge ends up with the correct status", challenge_id: 2, expected_status: "queued"
        end

        context "when the guess is correct but it's not the last attempt needed to complete the challenge" do
          let(:request_message) { "foo" }

          include_examples "it creates an attempt with the correct result status and texts drew",
                           expected_status: "correct_active_insufficient"
          include_examples "the challenge ends up with the correct status", challenge_id: 1, expected_status: "active"
          include_examples "the challenge ends up with the correct status", challenge_id: 2, expected_status: "queued"
        end

        context "when the guess is correct and it's the last guess needed to complete the challenge" do
          let(:request_message) { "foo" }

          before do
            challenge.update(current_streak: challenge.required_streak_for_completion - 1)
          end

          include_examples "it creates an attempt with the correct result status and texts drew",
                           expected_status: "correct_active_sufficient"
          include_examples "the challenge ends up with the correct status", challenge_id: 1, expected_status: "complete"
          include_examples "the challenge ends up with the correct status", challenge_id: 2, expected_status: "active"
        end
      end

      context "when it is an already-completed challenge" do
        before do
          challenge.complete!
        end

        context "when the guess is incorrect" do
          let(:request_message) { "abc" }

          include_examples "it creates an attempt with the correct result status and texts drew",
                           expected_status: "incorrect_complete"
          include_examples "the challenge ends up with the correct status", challenge_id: 1, expected_status: "active"
        end

        context "when the guess is correct" do
          let(:request_message) { "foo" }

          include_examples "it creates an attempt with the correct result status and texts drew",
                           expected_status: "correct_complete"
          include_examples "the challenge ends up with the correct status", challenge_id: 1, expected_status: "complete"
        end
      end
    end

    context "when there are no queries" do
      let(:request_message) { "abc" }

      it "does not create an attempt" do
        expect { post_create }.to change(Attempt, :count).by(0)
      end
    end

    context "when the last query was already attempted" do
      let(:request_message) { "abc" }

      before do
        create(:attempt)
      end

      it "does not create an attempt" do
        expect { post_create }.to change(Attempt, :count).by(0)
      end
    end
  end
end
