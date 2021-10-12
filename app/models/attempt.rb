# frozen_string_literal: true

class Attempt < ApplicationRecord
  enum result_status: [
    :incorrect_active, # attempt was incorrect for an active challenge
    :correct_active_insufficient, # attempt was correct for an active challenge, but more are needed for completion
    :correct_active_sufficient, # attempt was correct for an active challenge, and the challenge is now complete
    :incorrect_complete, # attempt was incorrect for an already-completed challenge
    :correct_complete # attempt was correct for an already-complete challenge
  ]

  belongs_to :question

  has_one :challenge, through: :question

  scope :for_challenge, ->(challenge) { joins(:question).where(questions: {challenge: challenge}) }

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
    case result_status
    when "incorrect_active"
      "Estas equivocado, idiota. The correct answer is '#{question.correct_text}'."
    when "correct_active_insufficient"
      if challenge.correct_attempts_still_required == 1
        "Good job, that's correct! You only need 1 more correct guess to complete this challenge!"
      else
        "Good job, that's correct! " \
            "#{challenge.correct_attempts_still_required} more correct guesses " \
            "in a row needed to complete this challenge."
      end
    when "correct_active_sufficient"
      "Good job, that's correct! You've completed this challenge!"
    when "incorrect_complete"
      "That's incorrect. This challenge has been reactivated."
    when "correct_complete"
      "That's correct. Looks like you still know this one"
    end
  end

  def get_test_text(raw_text)
    tokenizer.tokenize(raw_text).join(" ")
  end

  def challenge_test_text
    get_test_text(question.correct_text)
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
    if question.response_language == "spanish"
      :es
    else
      :en
    end
  end

  # runs before challenge status is updated
  def compute_result_status
    if correct?
      if challenge.complete?
        :correct_complete
      elsif challenge.correct_attempts_still_required == 1
        :correct_active_sufficient
      else
        :correct_active_insufficient
      end
    elsif challenge.complete?
      :incorrect_complete
    else
      :incorrect_active
    end
  end

  def self.create_and_process(attrs)
    create(attrs).tap do |attempt|
      attempt.update(result_status: attempt.compute_result_status)
      attempt.challenge.process_attempt(attempt)
      attempt.question.student.text(attempt.response_message)
    end
  end
end
