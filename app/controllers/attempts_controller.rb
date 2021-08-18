# frozen_string_literal: true

class AttemptsController < ApplicationController
  def index
    return render json: {errors: "challenge_id is required"}, status: :not_found if params[:challenge_id].nil?

    @attempts = Attempt.for_challenge(params[:challenge_id])

    render json: @attempts
  end
end
