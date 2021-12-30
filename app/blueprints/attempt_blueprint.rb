# frozen_string_literal: true

class AttemptBlueprint < ApplicationBlueprint
  identifier :id

  fields :text, :created_at

  field :correct?, name: :is_correct

  field :challenge_id do |attempt|
    attempt.question.challenge_id
  end

  field :question_language do |attempt|
    attempt.question.language
  end
end
