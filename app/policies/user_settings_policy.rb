# frozen_string_literal: true

class UserSettingsPolicy < ApplicationPolicy
  def update?
    record.user_id == user.id
  end
end
