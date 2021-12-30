# frozen_string_literal: true

class StudentTeacherInvitationBlueprint < ApplicationBlueprint
  fields :recipient_name,
         :recipient_phone_number,
         :creator_id,
         :requested_role,
         :status,
         :created_at

  field :creator_username do |invitation|
    invitation.creator.username
  end

  field :recipient_id do |invitation, options|
    next nil if invitation.recipient.nil? || invitation.recipient.id != options[:current_user_id]

    invitation.recipient.id
  end
end
