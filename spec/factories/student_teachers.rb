# frozen_string_literal: true

FactoryBot.define do
  factory :student_teacher do
    student factory: :user
    teacher factory: :user
  end
end
