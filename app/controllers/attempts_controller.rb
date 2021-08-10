# frozen_string_literal: true

class AttemptsController < ApplicationController
  def index
    @attempts = Attempt.for_challenge(params[:challenge_id])

    render json: @attempts
  end
end
