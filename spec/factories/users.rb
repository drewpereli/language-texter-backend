# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { "luther_manhole" }
    phone_number { "1234567890" }
    password { "my-password" }
    password_confirmation { "my-password" }
    password_digest { "my-password-digest" }
  end
end
