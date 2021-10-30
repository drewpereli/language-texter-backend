# frozen_string_literal: true

require "rails_helper"

RSpec.describe Question, type: :model do
  describe "#message" do
    subject(:message) { question.message }

    let(:challenge) { create(:challenge, spanish_text: "foo", english_text: "bar") }

    context "when language is spanish" do
      let(:question) { create(:question, challenge: challenge, language: "spanish") }

      it { is_expected.to eql("What does \"foo\" mean?") }

      context "when the challenge has a spanish note" do
        before do
          challenge.update(spanish_text_note: "foo bar")
        end

        it { is_expected.to eql("What does \"foo\" mean? (Note: foo bar)") }
      end

      context "when the challenge has a spanish note but it's an empty string" do
        before do
          challenge.update(spanish_text_note: "")
        end

        it { is_expected.to eql("What does \"foo\" mean?") }
      end
    end

    context "when language is english" do
      let(:question) { create(:question, challenge: challenge, language: "english") }

      it { is_expected.to eql("How do you say \"bar\" in spanish?") }

      context "when the challenge has an english note" do
        before do
          challenge.update(english_text_note: "foo bar")
        end

        it { is_expected.to eql("How do you say \"bar\" in spanish? (Note: foo bar)") }
      end

      context "when the challenge has an english note but it's an empty string" do
        before do
          challenge.update(english_text_note: "")
        end

        it { is_expected.to eql("How do you say \"bar\" in spanish?") }
      end
    end
  end

  describe "#reminder_message" do
    subject(:reminder_message) { question.reminder_message }

    let(:question) { create(:question) }

    it "is correct" do
      expect(reminder_message).to eql("Reminder: #{question.message}")
    end
  end

  describe "#needs_reminder?" do
    subject(:needs_reminder?) { question.needs_reminder? }

    include_context "with twilio_client stub"

    context "when it's a newly-sent question" do
      let(:question) { create(:question) }

      before { question.send_message }

      it { is_expected.to be_falsey }
    end

    context "when it was sent a while ago" do
      let(:question) do
        create(:question, created_at: Time.now - described_class::REMINDER_DELAY - 1.minute,
                          last_sent_at: Time.now - described_class::REMINDER_DELAY - 1.minute)
      end

      it { is_expected.to be_truthy }
    end

    context "when it was sent a while ago but it's been attempted'" do
      let(:question) do
        create(:question, created_at: Time.now - described_class::REMINDER_DELAY - 1.minute,
                          last_sent_at: Time.now - described_class::REMINDER_DELAY - 1.minute)
      end

      before do
        create(:attempt, question: question)
      end

      it { is_expected.to be_falsey }
    end

    context "when it was sent a while ago but a reminder was sent recently" do
      let(:question) do
        create(:question, created_at: Time.now - described_class::REMINDER_DELAY - 1.minute, last_sent_at: Time.now)
      end

      it { is_expected.to be_falsey }
    end
  end
end
