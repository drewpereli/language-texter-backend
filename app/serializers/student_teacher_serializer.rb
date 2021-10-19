# frozen_string_literal: true

class StudentTeacherSerializer < ActiveModel::Serializer
  attributes :id,
             :student_id,
             :student_username,
             :teacher_id,
             :teacher_username

  def student_username
    object.student.username
  end

  def teacher_username
    object.teacher.username
  end
end
