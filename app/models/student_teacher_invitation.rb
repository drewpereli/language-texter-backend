# frozen_string_literal: true

class StudentTeacherInvitation < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  # :recipient_phone_number is required, but does not have to correspond to a user in users table
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_phone_number", primary_key: "phone_number",
                         optional: true

  enum requested_role: %i[student teacher]
  enum status: %i[sent accepted rejected]

  validates :creator, :recipient_name, :recipient_phone_number, presence: true
  validates_uniqueness_of :creator, scope: %i[recipient_phone_number requested_role]
  validates_plausible_phone :recipient_phone_number
  phony_normalize :recipient_phone_number, country_code: "US"

  validate :validate_weekly_invite_limit
  validate :validate_recipient_is_not_creator

  WEEKLY_INVITE_LIMIT = 5

  def respond_and_notify(new_status)
    return unless %w[accepted rejected].include?(new_status)

    update(status: new_status)

    return unless valid?

    send_response_message

    return unless accepted?

    new_student = requested_role == "student" ? recipient : creator
    new_teacher = requested_role == "student" ? creator : recipient

    StudentTeacher.create(student: new_student, teacher: new_teacher)
  end

  def send_invitation_message
    twilio_client.text_number(recipient_phone_number, invitation_message)
  end

  def self.create_and_send(attrs)
    create(attrs).tap do |invitation|
      invitation.send_invitation_message if invitation.valid?
    end
  end

  private

  def send_response_message
    twilio_client.text_number(creator.phone_number, response_message)
  end

  def invitation_message
    "Hey there! #{creator.username} has invited you to be their teacher at spanishtexter.com. "\
    "Click this link to #{recipient.nil? ? "create an account" : "respond to the invitation"}! #{link}"
  end

  def response_message
    if accepted?
      "#{recipient_name} accepted your invitation!"
    elsif rejected?
      "#{recipient_name} rejected your invitation."
    end
  end

  def link
    File.join(Rails.application.credentials.front_end_url, "/invitations")
  end

  def validate_weekly_invite_limit
    return if creator.invitations_sent_within_last_week.count < WEEKLY_INVITE_LIMIT

    errors.add(:base,
               "Cannot send more than #{WEEKLY_INVITE_LIMIT} invites per week")
  end

  def validate_recipient_is_not_creator
    return unless creator.phone_number == recipient_phone_number

    errors.add(:base,
               "You cannot send an invitation to yourself")
  end

  def twilio_client
    @twilio_client ||= TwilioClient.new
  end
end
