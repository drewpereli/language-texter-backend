class CreateQueries < ActiveRecord::Migration[6.1]
  def change
    create_table :queries do |t|
      t.integer :language, null: false

      t.belongs_to :user, null: false
      t.belongs_to :challenge, null: false

      t.timestamps
    end
  end
end
