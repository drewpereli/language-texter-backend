# frozen_string_literal: true

class UserSettings < ApplicationRecord
  self.table_name = "user_settings"

  belongs_to :user

  validates :timezone, :user, presence: true
  validates_uniqueness_of :user_id
end
