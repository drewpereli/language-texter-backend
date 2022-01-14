class AddTextTimesUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :earliest_text_time, :time, null: false, default: "09:00:00"
    add_column :user_settings, :latest_text_time, :time, null: false, default: "22:00:00"
  end
end
