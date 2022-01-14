# frozen_string_literal: true

FactoryBot.define do
  factory :student_teacher_invitation do
    creator factory: :user

    recipient_name { "Fennel Cartwright" }

    sequence :recipient_phone_number do |n|
      "+1333#{n.to_s.rjust(7, "0")}"
    end
  end
end
