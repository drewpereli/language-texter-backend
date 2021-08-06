# frozen_string_literal: true

class ChallengeSerializer < ActiveModel::Serializer
  attributes :id,
             :spanish_text,
             :english_text,
             :required_streak_for_completion,
             :is_complete,
             :created_at,
             :user_id,
             :current_streak # I know this is an N+1 query...
end
