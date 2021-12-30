# frozen_string_literal: true

class ChallengeBlueprint < ApplicationBlueprint
  fields :spanish_text,
         :english_text,
         :spanish_text_note,
         :english_text_note,
         :required_score,
         :status,
         :created_at,
         :student_id,
         :creator_id

  field :current_score do |challenge|
    if challenge.active?
      challenge.current_score
    elsif challenge.queued?
      0
    else # if challenge.complete?
      challenge.required_score
    end
  end
end
