class ChangeStreakToScore < ActiveRecord::Migration[6.1]
  def change
    rename_column :challenges, :required_streak_for_completion, :required_score
    rename_column :challenges, :current_streak, :current_score
    change_column_default :challenges, :required_score, nil
  end
end
