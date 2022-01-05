class ConvertTextTimeFieldsToStrings < ActiveRecord::Migration[6.1]
  def change
    change_column :user_settings, :earliest_text_time, :string, null: false, default: "09:00"
    change_column :user_settings, :latest_text_time, :string, null: false, default: "22:00"
  end
end
