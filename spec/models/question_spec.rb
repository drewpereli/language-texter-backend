# frozen_string_literal: true

require "rails_helper"

RSpec.describe Question, type: :model do
  describe "#message" do
    subject(:message) { question.message }

    let(:challenge) { create(:challenge, learning_language_text: "foo", native_language_text: "bar") }

    context "when language is learning_language" do
      let(:question) { create(:question, challenge: challenge, language: "learning_language") }

      it { is_expected.to eql("What does \"foo\" mean?") }

      context "when the challenge has a learning_language note" do
        before do
          challenge.update(learning_language_text_note: "foo bar")
        end

        it { is_expected.to eql("What does \"foo\" mean? (Note: foo bar)") }
      end

      context "when the challenge has a learning_language note but it's an empty string" do
        before do
          challenge.update(learning_language_text_note: "")
        end

        it { is_expected.to eql("What does \"foo\" mean?") }
      end
    end

    context "when language is native_language" do
      let(:question) { create(:question, challenge: challenge, language: "native_language") }

      it { is_expected.to eql("How do you say \"bar\" in learning_language?") }

      context "when the challenge has an native_language note" do
        before do
          challenge.update(native_language_text_note: "foo bar")
        end

        it { is_expected.to eql("How do you say \"bar\" in learning_language? (Note: foo bar)") }
      end

      context "when the challenge has an native_language note but it's an empty string" do
        before do
          challenge.update(native_language_text_note: "")
        end

        it { is_expected.to eql("How do you say \"bar\" in learning_language?") }
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

    let(:reminder_frequency) { "hourly_reminders" }

    before do
      question.student.user_settings.update(reminder_frequency: reminder_frequency)
    end

    include_context "with twilio_client stub"

    context "when it's a newly-sent question" do
      let(:question) { create(:question) }

      before { question.send_message }

      it { is_expected.to be_falsey }
    end

    context "when it was sent a long time ago and no reminders have been sent yet" do
      let(:question) do
        create(:question, created_at: Time.now - 5.hours, last_sent_at: Time.now - 5.hours)
      end

      it { is_expected.to be_truthy }
    end

    context "when it was sent a long time ago and no reminders have been sent yet, but reminder frequency is low" do
      let(:reminder_frequency) { "daily_reminders" }

      let(:question) do
        create(:question, created_at: Time.now - 5.hours, last_sent_at: Time.now - 5.hours)
      end

      it { is_expected.to be_falsey }
    end

    context "when it was sent a long time ago and no reminders have been sent yet but user has reminders off" do
      let(:reminder_frequency) { "no_reminders" }

      let(:question) do
        create(:question, created_at: Time.now - 5.years, last_sent_at: Time.now - 5.years)
      end

      it { is_expected.to be_falsey }
    end

    context "when it was sent a while ago but it's been attempted'" do
      let(:question) do
        create(:question, created_at: Time.now - 5.hours, last_sent_at: Time.now - 5.hours)
      end

      before do
        create(:attempt, question: question)
      end

      it { is_expected.to be_falsey }
    end

    context "when it was sent a while ago but a reminder was sent recently" do
      let(:question) do
        create(:question, created_at: Time.now - 5.hours, last_sent_at: Time.now)
      end

      it { is_expected.to be_falsey }
    end
  end
end
