# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    challenge

    sequence :language do |n|
      n.even? ? "native_language" : "learning_language"
    end

    trait :expecting_native_language_response do
      language { "learning_language" }
    end
  end
end
