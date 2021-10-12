# frozen_string_literal: true

FactoryBot.define do
  factory :attempt do
    question

    text { "my attempt text" }

    trait :correct do
      text { question.correct_text }
    end

    trait :incorrect do
      text { "#{question.correct_text}abc" }
    end
  end
end
