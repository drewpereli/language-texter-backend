class AddReminderFrequencyToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :reminder_frequency, :integer
  end
end
