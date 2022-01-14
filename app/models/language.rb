# frozen_string_literal: true

class Language < ApplicationRecord
  validates :code, :name, :native_name, presence: true
  validates :code, uniqueness: true
end
