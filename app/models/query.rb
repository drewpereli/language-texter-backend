# frozen_string_literal: true

class Query < ApplicationRecord
  enum language: %i[spanish english]

  belongs_to :challenge
  belongs_to :user
end
