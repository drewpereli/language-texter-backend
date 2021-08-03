# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, :phone_number, :password, :password_confirmation, presence: true
  validates :username, uniqueness: true

  has_many :challenges

  def token
    JWT.encode({user_id: id}, Rails.application.secrets.secret_key_base)
  end

  def text(message)
    twilio_client.text_number(phone_number, message)
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end
end
