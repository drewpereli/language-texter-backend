# frozen_string_literal: true

FactoryBot.define do
  factory :query do
    challenge
    user

    sequence :language do |n|
      n.even? ? "english" : "spanish"
    end
  end
end
