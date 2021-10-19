# frozen_string_literal: true

class StudentTeacherInvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :creator_username,
             :recipient_name,
             :recipient_phone_number,
             :requested_role,
             :status

  def creator_username
    object.creator.username
  end
end
