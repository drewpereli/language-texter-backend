# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    student factory: :user
    creator factory: :user

    sequence :learning_language_text do |n|
      "my-learning_language-text=#{n}"
    end

    sequence :native_language_text do |n|
      "my-native_language-text=#{n}"
    end

    required_score { 20 }
  end
end
