# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence :username do |n|
      "luther_manhole-#{n}"
    end

    sequence :phone_number do |n|
      "+1222#{n.to_s.rjust(7, "0")}"
    end

    password { "my-long-password" }
    password_confirmation { "my-long-password" }
  end
end
