class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :phone_number, null: false
      t.string :password_digest, null: false

      t.timestamps

      t.index [ :username ], unique: true
    end
  end
end
