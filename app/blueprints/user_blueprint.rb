# frozen_string_literal: true

class UserBlueprint < ApplicationBlueprint
  fields :username

  field :student_ids do |user|
    user.students.ids
  end

  field :teacher_ids do |user|
    user.teachers.ids
  end

  view :for_current_user do
    association :user_settings, blueprint: UserSettingsBlueprint
  end
end
