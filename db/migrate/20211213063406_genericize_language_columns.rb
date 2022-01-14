class GenericizeLanguageColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :challenges, :english_text, :native_language_text
    rename_column :challenges, :english_text_note, :native_language_text_note
    rename_column :challenges, :spanish_text, :learning_language_text
    rename_column :challenges, :spanish_text_note, :learning_language_text_note
  end
end
