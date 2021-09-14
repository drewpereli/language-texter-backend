# frozen_string_literal: true

class Challenge < ApplicationRecord
  enum status: %i[queued active complete]

  belongs_to :user

  has_many :phrases, dependent: :destroy  
  has_many :queries, dependent: :destroy
  has_many :attempts, through: :queries

  validates :spanish_text, :english_text, :user, presence: true

  MAX_ACTIVE = 10

  def streak_enough_for_completion?
    current_streak >= required_streak_for_completion
  end

  def correct_attempts_still_required
    [0, required_streak_for_completion - current_streak].max
  end

  def mark_as_complete
    complete!

    self.class.first_in_queue&.active! if self.class.need_more_active?

    christina = User.find_by(username: "christina")

    christina&.text("Drew has completed the challenge \"#{spanish_text}\"!")
  end

  def process_attempt(attempt)
    case attempt.result_status
    when "incorrect_active"
      update(current_streak: 0)
    when "correct_active_insufficient", "correct_complete"
      increment!(:current_streak)
    when "correct_active_sufficient"
      increment!(:current_streak)
      mark_as_complete
    when "incorrect_complete"
      update(current_streak: 0)
      active!
    end
  end

  class << self
    def create_and_process(attrs)
      attrs[:spanish_text] = attrs[:spanish_text]&.strip
      attrs[:english_text] = attrs[:english_text]&.strip

      create(attrs).tap do |challenge|
        challenge.update(status: "active") if need_more_active?

        if challenge.valid?
          User.drew.text("New challenged added! '#{challenge.spanish_text}' / '#{challenge.english_text}'.")
        end
      end
    end

    def need_more_active?
      active.count < MAX_ACTIVE
    end

    def first_in_queue
      queued.first
    end
  end
end
