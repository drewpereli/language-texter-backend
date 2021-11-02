# frozen_string_literal: true

class ChallengeSerializer < ActiveModel::Serializer
  attributes :id,
             :spanish_text,
             :english_text,
             :spanish_text_note,
             :english_text_note,
             :required_score,
             :status,
             :created_at,
             :student_id,
             :creator_id,
             :current_score

  def current_score
    if object.active?
      object.current_score
    elsif object.queued?
      0
    else # if object.complete?
      object.required_score
    end
  end
end
