# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(id: [user, *user.inviters, *user.students, *user.teachers])
    end
  end

  def create?
    true
  end
end
