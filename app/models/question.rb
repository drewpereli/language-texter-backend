# frozen_string_literal: true

class Question < ApplicationRecord
  enum language: %i[spanish english]

  belongs_to :challenge

  has_one :student, through: :challenge

  has_one :attempt, dependent: :destroy

  REMINDER_DELAY = 1.hour

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
    if response_language == "english"
      challenge.english_text
    else
      challenge.spanish_text
    end
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end

  def response_language
    if language == "spanish"
      "english"
    else
      "spanish"
    end
  end

  def time_since_last_sent
    Time.now - last_sent_at
  end

  def attempted?
    attempt.present?
  end

  def needs_reminder?
    !attempted? && time_since_last_sent > REMINDER_DELAY
  end

  def self.current_active
    return nil if last.attempt.present?

    last
  end

  private

  def message_challenge_portion
    if spanish?
      event_messages[:spanish_challenge]
    else
      event_messages[:english_challenge]
    end
  end

  def message_note_portion
    if spanish? && challenge.spanish_text_note.present?
      event_messages[:spanish_note]
    elsif english? && challenge.english_text_note.present?
      event_messages[:english_note]
    end
  end

  def event_message_variables
    {
      spanish_text: challenge.spanish_text.strip,
      english_text: challenge.english_text.strip,
      spanish_note: challenge.spanish_text_note,
      english_note: challenge.english_text_note
    }
  end
end
