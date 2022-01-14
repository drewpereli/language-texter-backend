class AddDefaultChallengeLanguageToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :default_challenge_language_id, :integer
  end
end
