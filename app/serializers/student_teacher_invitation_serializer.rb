# frozen_string_literal: true

class StudentTeacherInvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :recipient_id,
             :recipient_name,
             :recipient_phone_number,
             :creator_id,
             :creator_username,
             :requested_role,
             :status,
             :created_at

  def creator_username
    object.creator.username
  end

  def recipient_id
    object.recipient&.id
  end
end
