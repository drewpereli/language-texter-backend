# frozen_string_literal: true

class StudentTeacher < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :teacher, class_name: "User", foreign_key: "teacher_id"

  validates :student, :teacher, presence: true
  validates :student, uniqueness: {scope: :teacher}
end
