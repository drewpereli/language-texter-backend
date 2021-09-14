class SetPhraseForEachQuery < ActiveRecord::Migration[6.1]
  def up
    Query.find_each do |query|
      phrase = Phrase.where(challenge_id: query.challenge_id, language: query.language).first

      query.update!(phrase_id: phrase.id)
    end
  end

  # Here, we'll associate each query with a challenge again
  # If you read through the migrations backwards starting a few ahead of this, it makes more sense
  # In the next migration, we delete the challenge association
  def down
    Query.find_each do |query|
      phrase = Phrase.find(query.phrase_id)

      query.update!(challenge_id: phrase.challenge_id)
    end
  end
end
