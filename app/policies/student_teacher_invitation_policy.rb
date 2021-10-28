# frozen_string_literal: true

class StudentTeacherInvitationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(creator: user).or(scope.where(recipient: user))
    end
  end

  def create?
    record.creator_id == user.id
  end

  # right now, the only thing you can update on the invitation is the status (i.e. whether it is accepted or rejected),
  # so we want to make sure it's the recipient doing the updating
  def update?
    record.recipient.present? && record.recipient.id == user.id
  end

  def destroy?
    create?
  end
end
