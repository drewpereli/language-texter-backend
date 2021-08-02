# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, :phone_number, :password, :password_confirmation, presence: true
  validates :username, uniqueness: true
end
