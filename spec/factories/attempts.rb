# frozen_string_literal: true

FactoryBot.define do
  factory :attempt do
    query

    text { "my attempt text" }

    trait :correct do
      text { query.correct_text }
    end

    trait :incorrect do
      text { "#{query.correct_text}abc" }
    end
  end
end
