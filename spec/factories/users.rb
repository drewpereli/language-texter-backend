# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence :username do |n|
      "luther_manhole-#{n}"
    end

    sequence :phone_number do |n|
      "+1#{n.to_s.rjust(9, "0")}"
    end

    password { "my-password" }
    password_confirmation { "my-password" }
  end
end
