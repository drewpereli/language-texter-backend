# frozen_string_literal: true

class AttemptSerializer < ActiveModel::Serializer
  attributes :id, :text, :query_language, :is_correct, :challenge_id, :created_at

  def challenge_id
    object.query.challenge_id
  end

  def query_language
    object.query.language
  end

  def is_correct # rubocop:disable Naming/PredicateName
    object.correct?
  end
end
