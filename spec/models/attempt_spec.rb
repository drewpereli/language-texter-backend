# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attempt, type: :model do
  describe "#correct?" do
    subject(:correct) { attempt.correct? }

    let(:u1) { create(:user, username: "u1", phone_number: "abc") }
    let(:u2) { create(:user, username: "u2", phone_number: "def") }
    let(:challenge) { create(:challenge, spanish_text: "amigo", english_text: "friend", user: u1) }
    let(:query) { create(:query, challenge: challenge, user: u2, language: language) }
    let(:attempt) { create(:attempt, query: query, text: text) }

    context "when test is spanish and response is correct" do
      let(:language) { "spanish" }
      let(:text) { "friend" }

      it { is_expected.to be_truthy }
    end

    context "when test is spanish and response is incorrect" do
      let(:language) { "spanish" }
      let(:text) { "asdfasdf" }

      it { is_expected.to be_falsey }
    end

    context "when test is english and response is correct" do
      let(:language) { "english" }
      let(:text) { "amigo" }

      it { is_expected.to be_truthy }
    end

    context "when test is english and response is incorrect" do
      let(:language) { "english" }
      let(:text) { "asdfasdf" }

      it { is_expected.to be_falsey }
    end

    context "when text matches but has extra whitespace" do
      let(:language) { "english" }
      let(:text) { "     amigo    " }

      it { is_expected.to be_truthy }
    end

    context "when text matches but has mismatched case" do
      let(:language) { "english" }
      let(:text) { "Amigo" }

      it { is_expected.to be_truthy }
    end
  end
end
