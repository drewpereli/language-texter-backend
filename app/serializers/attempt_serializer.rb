# frozen_string_literal: true

class AttemptSerializer < ActiveModel::Serializer
  attributes :id, :text, :question_language, :is_correct, :challenge_id, :created_at

  def challenge_id
    object.question.challenge_id
  end

  def question_language
    object.question.language
  end

  def is_correct # rubocop:disable Naming/PredicateName
    object.correct?
  end
end
