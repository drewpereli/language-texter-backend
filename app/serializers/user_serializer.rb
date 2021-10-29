# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :student_ids, :teacher_ids

  has_one :user_settings, if: :serializing_current_user?

  def student_ids
    object.students.ids
  end

  def teacher_ids
    object.teachers.ids
  end

  def serializing_current_user?
    object.id == current_user&.id
  end
end
