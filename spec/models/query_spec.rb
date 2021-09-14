# frozen_string_literal: true

require "rails_helper"

RSpec.describe Query, type: :model do
  describe "#message" do
    subject(:message) { query.message }

    let(:challenge) { create(:challenge, spanish_text: "foo", english_text: "bar") }

    context "when language is spanish" do
      let(:query) { create(:query, challenge: challenge, language: "spanish") }

      it { is_expected.to eql("What does 'foo' mean?") }

      context "when the challenge has a spanish note" do
        before do
          challenge.update(spanish_text_note: "foo bar")
        end

        it { is_expected.to eql("What does 'foo' mean? (Note: foo bar)") }
      end

      context "when the challenge has a spanish note but it's an empty string" do
        before do
          challenge.update(spanish_text_note: "")
        end

        it { is_expected.to eql("What does 'foo' mean?") }
      end
    end

    context "when language is english" do
      let(:query) { create(:query, challenge: challenge, language: "english") }

      it { is_expected.to eql("How do you say 'bar' in spanish?") }

      context "when the challenge has an english note" do
        before do
          challenge.update(english_text_note: "foo bar")
        end

        it { is_expected.to eql("How do you say 'bar' in spanish? (Note: foo bar)") }
      end

      context "when the challenge has an english note but it's an empty string" do
        before do
          challenge.update(english_text_note: "")
        end

        it { is_expected.to eql("How do you say 'bar' in spanish?") }
      end
    end
  end
end
