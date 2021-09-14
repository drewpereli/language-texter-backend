class RemoveLanguageFromQueries < ActiveRecord::Migration[6.1]
  def up
    remove_column :queries, :language
  end

  def down
    add_column :queries, :language, :integer, null: false, default: 0

    Query.find_each do |query|
      phrase = Phrase.find(query.phrase_id)

      language_int = phrase.language == 0 || phrase.language == "spanish" ? 0 : 1

      query.update!(language: language_int)
    end
  end
end
