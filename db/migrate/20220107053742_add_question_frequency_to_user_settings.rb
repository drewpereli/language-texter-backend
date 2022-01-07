class AddQuestionFrequencyToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :question_frequency, :integer, null: false, default: 0
  end
end
