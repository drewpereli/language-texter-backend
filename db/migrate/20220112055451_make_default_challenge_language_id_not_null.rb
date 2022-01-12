class MakeDefaultChallengeLanguageIdNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :user_settings, :default_challenge_language_id, false
  end
end
