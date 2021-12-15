# frozen_string_literal: true

class Challenge < ApplicationRecord
  enum status: %i[queued active complete]

  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :language

  has_many :questions, dependent: :destroy
  has_many :attempts, through: :questions

  validates :language, :learning_language_text, :native_language_text, :student, :creator, presence: true

  MAX_ACTIVE = 10

  def streak_enough_for_completion?
    current_score >= required_score
  end

  def correct_attempts_still_required
    [0, required_score - current_score].max
  end

  def mark_as_complete
    complete!

    self.class.first_in_queue&.active! if self.class.need_more_active?

    creator.text(event_messages[:completed]) unless creator_id == student_id
  end

  def process_attempt(attempt)
    case attempt.result_status
    when "incorrect_active"
      update(current_score: 0)
    when "correct_active_insufficient", "correct_complete"
      increment!(:current_score)
    when "correct_active_sufficient"
      increment!(:current_score)
      mark_as_complete
    when "incorrect_complete"
      update(current_score: 0)
      active!
    end
  end

  def new_question
    question = Question.create(challenge: self, language: random_language)
    question.send_message
  end

  def send_creation_message
    student.text(event_messages[:created])
  end

  class << self
    def create_and_process(attrs)
      # Make sure to see before_validate and before_save for some other stuff that's happening here

      create(attrs).tap do |challenge|
        break challenge unless challenge.valid?

        challenge.update(status: "active") if need_more_active?

        challenge.send_creation_message if challenge.creator.id != challenge.student.id
      end
    end

    def need_more_active?
      active.count < MAX_ACTIVE
    end

    def first_in_queue
      queued.first
    end

    def random_active_not_last
      active.where.not(id: last_question.challenge_id).sample
    end

    def random_complete
      complete.sample
    end
  end

  private

  before_validation do |challenge|
    challenge.language = challenge.student&.user_settings&.default_challenge_language unless challenge.language
  end

  before_save do |challenge|
    challenge.learning_language_text = challenge.learning_language_text&.strip
    challenge.native_language_text = challenge.native_language_text&.strip
  end

  def random_language
    if rand < 0.66
      "native_language"
    else
      "learning_language"
    end
  end

  def event_message_variables
    {
      learning_language_text: learning_language_text.strip,
      native_language_text: native_language_text.strip,
      student_username: student.username
    }
  end
end
