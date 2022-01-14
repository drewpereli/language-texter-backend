# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_secure_token :confirmation_token

  validates :username, :phone_number, presence: true, uniqueness: true
  validates :password, :password_confirmation, presence: true, if: :password
  validates_length_of :password, within: 12..100, if: :password
  validates_plausible_phone :phone_number
  phony_normalize :phone_number, country_code: "US"

  has_many :challenges_assigned, class_name: "Challenge", foreign_key: "student_id"
  has_many :challenges_created, class_name: "Challenge", foreign_key: "creator_id"

  has_many :questions_assigned, through: :challenges_assigned, source: :questions

  has_many :student_teacher_invitations_sent, class_name: "StudentTeacherInvitation", foreign_key: "creator_id"
  has_many :student_teacher_invitations_received, class_name: "StudentTeacherInvitation",
                                                  foreign_key: "recipient_phone_number",
                                                  primary_key: "phone_number"

  has_many :inviters, through: :student_teacher_invitations_received, source: :creator

  has_many :student_teachers_where_student, class_name: "StudentTeacher", foreign_key: "student_id"
  has_many :student_teachers_where_teacher, class_name: "StudentTeacher", foreign_key: "teacher_id"

  has_many :students, through: :student_teachers_where_teacher
  has_many :teachers, through: :student_teachers_where_student

  has_one :user_settings, dependent: :destroy

  TIME_FOR_NEW_QUESTION_PROBABILITY = 0.1
  SEND_OLD_CHALLENGE_PROBABILITY = 0.1

  def send_question_if_time
    return unless appropriate_time_for_text?

    if last_question_waiting_on_attempt?
      last_question.send_reminder if last_question.needs_reminder?
    elsif enough_time_since_last_question?
      next_challenge&.new_question
    end
  end

  def jwt_token
    JWT.encode({user_id: id}, Rails.application.secret_key_base)
  end

  def text(message)
    twilio_client.text_number(phone_number, message)
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end

  def confirm!
    update!(confirmed: true, confirmation_token: nil)
  end

  def active_question
    last_question = Question.where(challenge: challenges_assigned).order(created_at: :desc).first

    return nil if last_question.nil?

    last_question.attempted? ? nil : last_question
  end

  def invitations_sent_within_last_week
    student_teacher_invitations_sent.where("created_at > ?", 1.week.ago)
  end

  def appropriate_time_for_text?
    current_hour = time_now.strftime("%H").to_i
    current_minute = time_now.strftime("%M").to_i

    current_minutes = current_hour * 60 + current_minute

    user_times = user_settings.numeric_text_times

    min_minutes = user_times[:earliest][:hour] * 60 + user_times[:earliest][:minute]
    max_minutes = user_times[:latest][:hour] * 60 + user_times[:latest][:minute]

    current_minutes >= min_minutes && current_minutes <= max_minutes
  end

  def last_question
    questions_assigned.order(created_at: :desc).first
  end

  def last_question_waiting_on_attempt?
    return false unless last_question

    !last_question.attempted?
  end

  def next_challenge
    active_count = challenges_assigned.active.count
    complete_count = challenges_assigned.complete.count

    return nil if active_count.zero? && complete_count.zero?

    if (rand < SEND_OLD_CHALLENGE_PROBABILITY && complete_count.positive?) || active_count.zero?
      challenges_assigned.complete.sample
    elsif last_question.present? && active_count > 1
      last_challenge = last_question.challenge

      challenges_assigned.active.where.not(id: last_challenge.id).sample
    else
      challenges_assigned.active.sample
    end
  end

  def enough_time_since_last_question?
    return false unless last_question&.attempted?

    seconds_since_last_question = time_now - last_question.created_at.in_time_zone(user_settings.timezone)

    seconds_required = question_frequency_hours.hours.in_seconds

    seconds_since_last_question > seconds_required
  end

  def question_frequency_hours
    freq = user_settings.question_frequency

    {
      "hourly_questions" => 1,
      "questions_every_two_hours" => 2,
      "questions_every_four_hours" => 4,
      "questions_every_eight_hours" => 8,
      "daily_questions" => 24
    }[freq]
  end

  def reminder_frequency_hours
    freq = user_settings.reminder_frequency

    {
      "no_reminders" => nil,
      "hourly_reminders" => 1,
      "reminders_every_four_hours" => 4,
      "daily_reminders" => 24
    }[freq]
  end

  def time_now
    Time.now.in_time_zone(user_settings.timezone)
  end

  def self.create_and_process(attrs)
    user = new(attrs.except(:timezone, :default_challenge_language_id))

    return user unless attrs[:timezone].present? && attrs[:default_challenge_language_id].present?

    user.save

    return user unless user.persisted?

    UserSettings.create(user: user, timezone: attrs[:timezone],
                        default_challenge_language_id: attrs[:default_challenge_language_id])

    front_end_url = Rails.env.production? ? "www.learning_languagetexter.com" : "localhost:4200"

    url = "#{front_end_url}/confirm-user?token=#{user.confirmation_token}&user_id=#{user.id}"

    message = "Please click this link to confirm your account. #{url}"

    user.text(message)

    user
  end

  def self.send_questions_if_time
    find_each(&:send_question_if_time)
  end
end
