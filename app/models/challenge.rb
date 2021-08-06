# frozen_string_literal: true

class Challenge < ApplicationRecord
  belongs_to :user

  has_many :queries
  has_many :attempts, through: :queries

  scope :incomplete, -> { where(is_complete: false) }

  def current_streak
    recent_attempts = attempts.order("attempts.created_at DESC").limit(required_streak_for_completion)

    count = 0

    recent_attempts.each do |attempt|
      break unless attempt.correct?

      count += 1
    end

    count
  end
end
