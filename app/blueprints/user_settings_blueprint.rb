# frozen_string_literal: true

class UserSettingsBlueprint < ApplicationBlueprint
  fields :user_id, :timezone

  association :default_challenge_language, blueprint: LanguageBlueprint
end
