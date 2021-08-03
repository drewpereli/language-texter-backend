class CreateChallenges < ActiveRecord::Migration[6.1]
  def change
    create_table :challenges do |t|
      t.string :spanish_text, null: false
      t.string :english_text, null: false
      t.integer :required_streak_for_completion, null: false, default: 20
      t.boolean :is_complete, null: false, default: false

      t.belongs_to :user, null: false

      t.timestamps
    end
  end
end
