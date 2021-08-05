# frozen_string_literal: true

class Challenge < ApplicationRecord
  belongs_to :user

  has_many :queries

  scope :incomplete, -> { where(is_complete: false) }

  def streak_count
    attempts = Attempt.joins(:query).where(queries: {challenge: self}).order("attempts.created_at DESC").limit(required_streak_for_completion)

    count = 0

    attempts.each do |attempt|
      break unless attempt.correct?

      count += 1
    end

    count
  end
end
