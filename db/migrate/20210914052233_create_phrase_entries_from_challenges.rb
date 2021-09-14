class CreatePhraseEntriesFromChallenges < ActiveRecord::Migration[6.1]
  def up
    Challenge.find_each do |challenge|
      Phrase.create!(challenge_id: challenge.id, language: 0, content: challenge.spanish_text, note: challenge.spanish_text_note)
      Phrase.create!(challenge_id: challenge.id, language: 1, content: challenge.english_text, note: challenge.english_text_note)
    end
  end

  def down 
    Phrase.find_each do |phrase|
      challenge = Challenge.find(phrase.challenge_id)

      if phrase.language == 0 || phrase.language == "spanish"
        challenge.update(spanish_text: phrase.content, spanish_text_note: phrase.note)
      else
        challenge.update(english_text: phrase.content, english_text_note: phrase.note)
      end
    end
  end
end
