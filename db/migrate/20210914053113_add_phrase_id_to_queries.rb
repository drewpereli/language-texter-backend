class AddPhraseIdToQueries < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :queries, :phrase
  end
end
