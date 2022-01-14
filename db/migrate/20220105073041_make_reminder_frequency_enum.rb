class MakeReminderFrequencyEnum < ActiveRecord::Migration[6.1]
  def change
    change_column_default :user_settings, :reminder_frequency, from: nil, to: 2
  end
end
