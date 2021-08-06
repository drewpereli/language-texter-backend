# frozen_string_literal: true

class Attempt < ApplicationRecord
  belongs_to :query

  def correct?
    raw_text_text = query.language == "spanish" ? query.challenge.english_text : query.challenge.spanish_text
    test_text = raw_text_text.downcase.strip
    response_text = text.downcase.strip

    test_text == response_text
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
end
