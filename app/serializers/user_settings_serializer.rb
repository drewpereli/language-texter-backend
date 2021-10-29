# frozen_string_literal: true

class UserSettingsSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :timezone
end
