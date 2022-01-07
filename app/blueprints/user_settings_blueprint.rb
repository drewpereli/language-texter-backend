# frozen_string_literal: true

class UserSettingsBlueprint < ApplicationBlueprint
  fields :user_id,
         :timezone,
         :default_challenge_language_id,
         :earliest_text_time,
         :latest_text_time,
         :question_frequency,
         :reminder_frequency
end
