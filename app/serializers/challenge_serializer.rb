# frozen_string_literal: true

class ChallengeSerializer < ActiveModel::Serializer
  attributes :id,
             :spanish_text,
             :english_text,
             :required_streak_for_completion,
             :status,
             :created_at,
             :user_id,
             :current_streak # I know this is an N+1 query...

  def current_streak
    if object.active?
      object.current_streak
    elsif object.queued?
      0
    else # if object.complete?
      object.required_streak_for_completion
    end
  end
end
