# frozen_string_literal: true

class ChallengeSerializer < ActiveModel::Serializer
  attributes :id,
             :spanish_text,
             :english_text,
             :spanish_text_note,
             :english_text_note,
             :required_streak_for_completion,
             :status,
             :created_at,
             :user_id,
             :current_streak

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
