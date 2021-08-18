# frozen_string_literal: true

class Query < ApplicationRecord
  enum language: %i[spanish english]

  belongs_to :challenge
  belongs_to :user

  has_one :attempt, dependent: :destroy

  def send_message
    twilio_client.text_number(user.phone_number, message)
    update(last_sent_at: Time.now)
  end

  def resend_message
    twilio_client.text_number(user.phone_number, "Respond you americano ignorante. #{message}")
    update(last_sent_at: Time.now)
  end

  def message
    if language == "spanish"
      "What does '#{challenge.spanish_text.strip}' mean?"
    else
      "How do you say '#{challenge.english_text.strip}' in spanish?"
    end
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
end
