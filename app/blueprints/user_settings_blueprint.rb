# frozen_string_literal: true

class UserSettingsBlueprint < ApplicationBlueprint
  fields :user_id, :timezone, :default_challenge_language_id
end
