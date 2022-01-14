# frozen_string_literal: true

FactoryBot.define do
  factory :language do
    sequence :code do |n|
      "code-#{n}"
    end

    sequence :name do |n|
      "name-#{n}"
    end

    sequence :native_name do |n|
      "native_name-#{n}"
    end
  end
end
