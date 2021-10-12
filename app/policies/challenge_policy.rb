# frozen_string_literal: true

class ChallengePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(creator: user).or(scope.where(student: user))
    end
  end

  def create?
    user.present?
  end

  def show?
    record.creator_id == user.id || record.student_id == user.id
  end

  def update?
    record.creator_id == user.id
  end

  def destroy?
    update?
  end
end
