# frozen_string_literal: true

class Question < ApplicationRecord
  enum language: %i[learning_language native_language]

  belongs_to :challenge

  has_one :student, through: :challenge

  has_one :attempt, dependent: :destroy

  def send_message
    twilio_client.text_number(student.phone_number, message)
    update(last_sent_at: Time.now)
  end

  def send_reminder
    twilio_client.text_number(student.phone_number, reminder_message)
    update(last_sent_at: Time.now)
  end

  def message
    [message_challenge_portion, message_note_portion].compact.join(" ")
  end

  def reminder_message
    "#{event_messages[:reminder_base]} #{message}"
  end

  def correct_text
    if response_language == "native_language"
      challenge.native_language_text
    else
      challenge.learning_language_text
    end
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end

  def response_language
    if language == "learning_language"
      "native_language"
    else
      "learning_language"
    end
  end

  def time_since_last_sent
    Time.now - last_sent_at
  end

  def attempted?
    attempt.present?
  end

  def needs_reminder?
    return false if attempted?

    return false if student.user_settings.no_reminders?

    time_since_last_sent > student.reminder_frequency_hours.hours
  end

  def self.current_active
    return nil if last.attempt.present?

    last
  end

  private

  def message_challenge_portion
    if learning_language?
      event_messages[:learning_language_challenge]
    else
      event_messages[:native_language_challenge]
    end
  end

  def message_note_portion
    if learning_language? && challenge.learning_language_text_note.present?
      event_messages[:learning_language_note]
    elsif native_language? && challenge.native_language_text_note.present?
      event_messages[:native_language_note]
    end
  end

  def event_message_variables
    {
      learning_language_text: challenge.learning_language_text.strip,
      native_language_text: challenge.native_language_text.strip,
      learning_language_note: challenge.learning_language_text_note,
      native_language_note: challenge.native_language_text_note
    }
  end
end
