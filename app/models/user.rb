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

  has_many :student_teacher_invitations_sent, class_name: "StudentTeacherInvitation", foreign_key: "creator_id"
  has_many :student_teacher_invitations_received, class_name: "StudentTeacherInvitation",
                                                  foreign_key: "recipient_phone_number",
                                                  primary_key: "phone_number"

  has_many :inviters, through: :student_teacher_invitations_received, source: :creator

  has_many :student_teachers_where_student, class_name: "StudentTeacher", foreign_key: "student_id"
  has_many :student_teachers_where_teacher, class_name: "StudentTeacher", foreign_key: "teacher_id"

  has_many :students, through: :student_teachers_where_teacher
  has_many :teachers, through: :student_teachers_where_student

  has_one :user_settings

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

  def self.create_and_send_confirmation(attrs)
    user = new(attrs.except(:timezone))

    return user unless attrs[:timezone].present?

    user.save

    return user unless user.persisted?

    UserSettings.create(user: user, timezone: attrs[:timezone])

    front_end_url = Rails.env.production? ? "www.spanishtexter.com" : "localhost:4200"

    url = "#{front_end_url}/confirm-user?token=#{user.confirmation_token}&user_id=#{user.id}"

    message = "Please click this link to confirm your account. #{url}"

    user.text(message)

    user
  end
end
