class CreateUserSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :user_settings do |t|
      t.string :timezone, null: false

      t.belongs_to :user, null: false
      
      t.timestamps
    end
  end
end
