# frozen_string_literal: true

class User < ApplicationRecord
  validates :username, :phone_number, :password_digest, presence: true
  validates :username, uniqueness: true
end
