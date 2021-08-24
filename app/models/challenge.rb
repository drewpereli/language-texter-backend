# frozen_string_literal: true

class Challenge < ApplicationRecord
  enum status: %i[queued active complete]
  
  belongs_to :user

  has_many :queries, dependent: :destroy
  has_many :attempts, through: :queries

  def current_streak
    recent_attempts = attempts.order("attempts.created_at DESC").limit(required_streak_for_completion)

    count = 0

    recent_attempts.each do |attempt|
      break unless attempt.correct?

      count += 1
    end

    count
  end

  def streak_enough_for_completion?
    current_streak >= required_streak_for_completion
  end

  def mark_as_complete
    complete!

    christina = User.find_by(username: "christina")

    christina&.text("Drew has completed the challenge \"#{spanish_text}\"!")
  end
end
