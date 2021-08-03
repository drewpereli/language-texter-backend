# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, :phone_number, :password, :password_confirmation, presence: true
  validates :username, uniqueness: true

  has_many :challenges

  def token
    JWT.encode({user_id: id}, Rails.application.secrets.secret_key_base)
  end
end
