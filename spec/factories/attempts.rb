# frozen_string_literal: true

FactoryBot.define do
  factory :attempt do
    query

    text { "my attempt text" }
  end
end
