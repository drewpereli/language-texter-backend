class RemoveTextColumnsFromChallenge < ActiveRecord::Migration[6.1]
  def change
    remove_column :challenges, :spanish_text, :string
    remove_column :challenges, :english_text, :string
    remove_column :challenges, :spanish_text_note, :string
    remove_column :challenges, :english_text_note, :string
  end
end
