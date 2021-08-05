class CreateAttempts < ActiveRecord::Migration[6.1]
  def change
    create_table :attempts do |t|

      t.string :text, null: false

      t.belongs_to :query, null: false

      t.timestamps
    end
  end
end
