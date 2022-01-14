# frozen_string_literal: true

FactoryBot.define do
  factory :user_settings do
    timezone { "US/Pacific" }

    default_challenge_language factory: :language
  end
end
