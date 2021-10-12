# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attempt, type: :model do
  describe ".create_and_process" do
    subject(:create_and_process) { described_class.create_and_process(question: question, text: "abc") }

    let(:question) { create(:question) }

    before do
      create(:user, :drew)
      allow(Rails.application.credentials).to receive(:twilio).and_return({account_ssid: 123, auth_token: "abc"})
      allow_any_instance_of(TwilioClient).to receive(:text_number).and_return(nil)
    end

    it "creates an attempt" do
      expect { create_and_process }.to change(described_class, :count).by(1)
    end

    it "sets the attempt result status" do
      attempt = create_and_process
      expect(attempt.result_status).not_to be_nil
      expect(attempt.result_status).to eql(attempt.compute_result_status.to_s)
    end

    it "calls process_attempt on the challenge" do
      expect_any_instance_of(Challenge).to receive(:process_attempt).with(instance_of(described_class))
      create_and_process
    end
  end

  describe "#correct?" do
    subject(:correct) { attempt.correct? }

    let(:u1) { create(:user, username: "u1") }
    let(:u2) { create(:user, username: "u2") }
    let(:challenge) do
      create(:challenge, spanish_text: challenge_spanish_text, english_text: challenge_english_text, creator: u1,
                         student: u2)
    end

    let(:question) { create(:question, challenge: challenge, language: question_language) }
    let(:attempt) { create(:attempt, question: question, text: attempt_text) }

    let(:challenge_spanish_text) { "amigo" }
    let(:challenge_english_text) { "friend" }

    context "when test is spanish and response is correct" do
      let(:question_language) { "spanish" }
      let(:attempt_text) { "friend" }

      it { is_expected.to be_truthy }
    end

    context "when test is spanish and response is incorrect" do
      let(:question_language) { "spanish" }
      let(:attempt_text) { "asdfasdf" }

      it { is_expected.to be_falsey }
    end

    context "when test is english and response is correct" do
      let(:question_language) { "english" }
      let(:attempt_text) { "amigo" }

      it { is_expected.to be_truthy }
    end

    context "when test is english and response is incorrect" do
      let(:question_language) { "english" }
      let(:attempt_text) { "asdfasdf" }

      it { is_expected.to be_falsey }
    end

    context "when text matches but has extra whitespace" do
      let(:question_language) { "english" }
      let(:attempt_text) { "     amigo    " }

      it { is_expected.to be_truthy }
    end

    context "when text matches but has mismatched case" do
      let(:question_language) { "english" }
      let(:attempt_text) { "Amigo" }

      it { is_expected.to be_truthy }
    end

    context "when text matches but has extra punctuation" do
      let(:question_language) { "english" }
      let(:attempt_text) { "amigo?" }

      it { is_expected.to be_truthy }
    end

    context "when the text matches except for a contraction in the answer" do
      let(:challenge_spanish_text) { "Cómo te llamas?" }
      let(:challenge_english_text) { "What is your name?" }
      let(:question_language) { "spanish" }
      let(:attempt_text) { "What's your name?" }

      it { is_expected.to be_truthy }
    end
  end

  describe "#compute_result_status" do
    subject(:compute_result_status) { attempt.compute_result_status }

    context "when attempt is correct" do
      let(:attempt) { create(:attempt, :correct) }

      context "when it's not the last attempt needed for an active challenge" do
        before do
          attempt.challenge.active!
        end

        it { is_expected.to be(:correct_active_insufficient) }
      end

      context "when it is the last attempt needed for an active challenge" do
        before do
          attempt.challenge.active!
          attempt.challenge.update(current_streak: attempt.challenge.required_streak_for_completion - 1)
        end

        it { is_expected.to be(:correct_active_sufficient) }
      end

      context "when it's for an already-completed challenge" do
        before do
          attempt.challenge.complete!
        end

        it { is_expected.to be(:correct_complete) }
      end
    end

    context "when attempt is incorrect" do
      let(:attempt) { create(:attempt, :incorrect) }

      context "when it's for an active challenge" do
        before do
          attempt.challenge.active!
        end

        it { is_expected.to be(:incorrect_active) }
      end

      context "when it's for an already-completed challenge" do
        before do
          attempt.challenge.complete!
        end

        it { is_expected.to be(:incorrect_complete) }
      end
    end
  end
end
