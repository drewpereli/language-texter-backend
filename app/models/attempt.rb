# frozen_string_literal: true

class Attempt < ApplicationRecord
  belongs_to :query

  def correct?
    raw_text_text = query.language == "spanish" ? query.challenge.english_text : query.challenge.spanish_text
    test_text = raw_text_text.downcase.strip
    response_text = text.downcase.strip

    test_text == response_text
  end
end
