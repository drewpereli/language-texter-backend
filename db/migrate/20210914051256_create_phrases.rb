class CreatePhrases < ActiveRecord::Migration[6.1]
  def change
    create_table :phrases do |t|
      t.string :content, null: false
      t.string :note
      t.integer :language, null: false, default: 0
      t.belongs_to :challenge, null: false

      t.timestamps
    end
  end
end
