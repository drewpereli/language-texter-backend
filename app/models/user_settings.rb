# frozen_string_literal: true

class UserSettings < ApplicationRecord
  self.table_name = "user_settings"

  belongs_to :user
  belongs_to :default_challenge_language, class_name: "Language", optional: true

  validates :timezone, :user, :default_challenge_language, presence: true
  validates_uniqueness_of :user_id
end
