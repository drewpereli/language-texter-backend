# frozen_string_literal: true

class StudentTeacherSerializer < ActiveModel::Serializer
  attributes :id,
             :student_id,
             :teacher_id
end
