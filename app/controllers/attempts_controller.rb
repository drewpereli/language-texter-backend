# frozen_string_literal: true

class AttemptsController < ApplicationController
  skip_after_action :verify_policy_scoped

  def index
    return render json: {errors: "challenge_id is required"}, status: :not_found if params[:challenge_id].nil?

    challenge = authorize(Challenge.find(params[:challenge_id]), :show?)

    @attempts = Attempt.for_challenge(challenge)

    render json: @attempts
  end
end
