# frozen_string_literal: true

class StudentTeacherPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(teacher: user).or(scope.where(student: user))
    end
  end

  def destroy?
    record.student_id == user.id || record.teacher_id == user.id
  end
end
