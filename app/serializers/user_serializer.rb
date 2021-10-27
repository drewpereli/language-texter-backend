# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :student_ids, :teacher_ids

  def student_ids
    object.students.ids
  end

  def teacher_ids
    object.teachers.ids
  end
end
