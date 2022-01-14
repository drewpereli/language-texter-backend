# frozen_string_literal: true

class StudentTeacher < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :teacher, class_name: "User", foreign_key: "teacher_id"

  validates :student, :teacher, presence: true
  validates :student, uniqueness: {scope: :teacher}
  validate :validate_student_is_not_teacher

  def validate_student_is_not_teacher
    return unless student.id == teacher.id

    errors.add(:base,
               "Student and teacher cannot be the same")
  end
end
