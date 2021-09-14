class AddNotesColumnsToChallenges < ActiveRecord::Migration[6.1]
  def change
    add_column :challenges, :spanish_text_note, :string
    add_column :challenges, :english_text_note, :string
  end
end
