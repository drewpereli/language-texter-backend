class RequireDefaultChallengeLanguageId < ActiveRecord::Migration[6.1]
  def change
    change_column_null :user_settings, :default_challenge_language_id, from: true, to: false
  end
end
