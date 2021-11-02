# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    student factory: :user
    creator factory: :user

    sequence :spanish_text do |n|
      "my-spanish-text=#{n}"
    end

    sequence :english_text do |n|
      "my-english-text=#{n}"
    end

    required_score { 20 }
  end
end
