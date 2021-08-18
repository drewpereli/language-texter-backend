# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    user

    sequence :spanish_text do |n|
      "my-spanish-text=#{n}"
    end

    sequence :english_text do |n|
      "my-spanish-text=#{n}"
    end
  end
end
