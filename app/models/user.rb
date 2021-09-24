# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_secure_token :confirmation_token

  validates :username, :phone_number, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :username, uniqueness: true

  has_many :challenges

  def token
    JWT.encode({user_id: id}, Rails.application.secret_key_base)
  end

  def text(message)
    twilio_client.text_number(phone_number, message)
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end

  def confirm!
    update!(confirmed: true, confirmation_token: nil)
  end

  def self.drew
    find_by(username: "drew")
  end
end
