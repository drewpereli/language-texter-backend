# frozen_string_literal: true

FactoryBot.define do
  factory :query do
    challenge

    sequence :language do |n|
      n.even? ? "english" : "spanish"
    end

    trait :expecting_english_response do
      language { "spanish" }
    end
  end
end
