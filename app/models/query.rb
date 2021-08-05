# frozen_string_literal: true

class Query < ApplicationRecord
  enum language: %i[spanish english]

  belongs_to :challenge
  belongs_to :user

  has_one :attempt

  def send_message
    twilio_client.text_number(user.phone_number, message)
  end

  def resend_message
    twilio_client.text_number(user.phone_number, "Respond you americano ignorante. #{message}")
  end

  def message
    if language == "spanish"
      "What does '#{challenge.spanish_text}' mean?"
    else
      "How do you say '#{challenge.english_text}' in spanish?"
    end
  end

  def correct_text
    if language == "spanish"
      challenge.english_text
    else
      challenge.spanish_text
    end
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end
end
