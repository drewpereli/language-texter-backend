class Phrase < ApplicationRecord
  enum language: %i[spanish english]

  belongs_to :challenge

  validates :content, :challenge, presence: true
end
