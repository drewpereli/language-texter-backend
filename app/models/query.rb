# frozen_string_literal: true

class Query < ApplicationRecord
  enum language: %i[spanish english]

  belongs_to :challenge

  has_one :student, through: :challenge

  has_one :attempt, dependent: :destroy

  def send_message
    twilio_client.text_number(student.phone_number, message)
    update(last_sent_at: Time.now)
  end

  def resend_message
    twilio_client.text_number(student.phone_number, "Respond you americano ignorante. #{message}")
    update(last_sent_at: Time.now)
  end

  def message
    [message_challenge_portion, message_note_portion].compact.join(" ")
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

  def self.current_active
    return nil if last.attempt.present?

    last
  end

  private

  def message_challenge_portion
    if spanish?
      "What does '#{challenge.spanish_text.strip}' mean?"
    else
      "How do you say '#{challenge.english_text.strip}' in spanish?"
    end
  end

  def message_note_portion
    if spanish? && challenge.spanish_text_note.present?
      "(Note: #{challenge.spanish_text_note})"
    elsif english? && challenge.english_text_note.present?
      "(Note: #{challenge.english_text_note})"
    end
  end
end
