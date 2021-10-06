class AddConfirmedAndConfirmationTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :confirmed, :boolean, null: false, default: false
    add_column :users, :confirmation_token, :string
  end
end
