# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { "luther_manhole" }
    phone_number { "1234567890" }
    password_digest { "my-password" }
  end
end
