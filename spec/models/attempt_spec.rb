# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attempt, type: :model do
  describe "#correct?" do
    subject(:correct) { attempt.correct? }

    let(:u1) { create(:user, username: "u1", phone_number: "abc") }
    let(:u2) { create(:user, username: "u2", phone_number: "def") }
    let(:challenge) do
      create(:challenge, spanish_text: challenge_spanish_text, english_text: challenge_english_text, user: u1)
    end
    let(:query) { create(:query, challenge: challenge, user: u2, language: query_language) }
    let(:attempt) { create(:attempt, query: query, text: attempt_text) }

    let(:challenge_spanish_text) { "amigo" }
    let(:challenge_english_text) { "friend" }

    context "when test is spanish and response is correct" do
      let(:query_language) { "spanish" }
      let(:attempt_text) { "friend" }

      it { is_expected.to be_truthy }
    end

    context "when test is spanish and response is incorrect" do
      let(:query_language) { "spanish" }
      let(:attempt_text) { "asdfasdf" }

      it { is_expected.to be_falsey }
    end

    context "when test is english and response is correct" do
      let(:query_language) { "english" }
      let(:attempt_text) { "amigo" }

      it { is_expected.to be_truthy }
    end

    context "when test is english and response is incorrect" do
      let(:query_language) { "english" }
      let(:attempt_text) { "asdfasdf" }

      it { is_expected.to be_falsey }
    end

    context "when text matches but has extra whitespace" do
      let(:query_language) { "english" }
      let(:attempt_text) { "     amigo    " }

      it { is_expected.to be_truthy }
    end

    context "when text matches but has mismatched case" do
      let(:query_language) { "english" }
      let(:attempt_text) { "Amigo" }

      it { is_expected.to be_truthy }
    end

    context "when text matches but has extra punctuation" do
      let(:query_language) { "english" }
      let(:attempt_text) { "amigo?" }

      it { is_expected.to be_truthy }
    end

    context "when the text matches except for a contraction in the answer" do
      let(:challenge_spanish_text) { "Cómo te llamas?" }
      let(:challenge_english_text) { "What is your name?" }
      let(:query_language) { "spanish" }
      let(:attempt_text) { "What's your name?" }

      it { is_expected.to be_truthy }
    end
  end
end
