# frozen_string_literal: true

class Attempt < ApplicationRecord
  belongs_to :query

  scope :for_challenge, ->(challenge) { joins(:query).where(queries: {challenge: challenge}) }

  DEFAULT_TOKENIZER_OPTIONS = {
    expand_contractions: true,
    remove_emoji: true,
    clean: true,
    downcase: true,
    punctuation: :none
  }.freeze

  def correct?
    challenge_test_text == response_test_text
  end

  def response_message
    if correct?
      current_streak = query.challenge.current_streak
      required_streak = query.challenge.required_streak_for_completion

      correct_attempts_still_required = [0, required_streak - current_streak].max

      case correct_attempts_still_required
      when 0
        "Good job, that's correct! You've completed this challenge!"
      when 1
        "Good job, that's correct! You only need 1 more correct guess to complete this challenge!"
      else
        "Good job, that's correct! " \
          "#{correct_attempts_still_required} more correct guesses in a row needed to complete this challenge."
      end

    else
      "Estas equivocado, idiota. The correct answer is '#{query.correct_text}'."
    end
  end

  def get_test_text(raw_text)
    tokenizer.tokenize(raw_text).join(" ")
  end

  def challenge_test_text
    get_test_text(query.correct_text)
  end

  def response_test_text
    get_test_text(text)
  end

  def tokenizer
    @tokenizer ||= PragmaticTokenizer::Tokenizer.new(
      {language: response_language_abbreviation}.merge(DEFAULT_TOKENIZER_OPTIONS)
    )
  end

  def response_language_abbreviation
    if query.response_language == "spanish"
      :es
    else
      :en
    end
  end
end
