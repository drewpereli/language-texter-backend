# frozen_string_literal: true

require "rails_helper"

RSpec.describe Challenge, type: :model do
  describe "#current_streak" do
    subject(:current_streak) { challenge.current_streak }

    let(:u1) { create(:user, username: "u1", phone_number: "abc") }
    let(:u2) { create(:user, username: "u2", phone_number: "def") }
    let(:challenge) do
      create(:challenge, spanish_text: "amigo", english_text: "friend", user: u1, required_streak_for_completion: 3)
    end

    context "when the user hasn't responded yet" do
      it { is_expected.to be(0) }
    end

    context "when the user has respondent with some correct and some incorrect and the last one was incorrect" do
      before do
        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "asdfasdfasdf",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))
      end

      it { is_expected.to be(0) }
    end

    context "when the user has respondent with some correct and some incorrect and the last one was correct" do
      before do
        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "asdfasdfasdf",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "amigo",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "english"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))
      end

      it "is the count of all the correct answers since the last incorrect answer" do
        expect(current_streak).to be(3)
      end
    end
  end
end
