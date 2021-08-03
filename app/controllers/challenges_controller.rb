# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :set_challenge, only: %i[update destroy]

  # GET /challenges
  def index
    @challenges = Challenge.all

    render json: @challenges
  end

  # POST /challenges
  def create
    @challenge = Challenge.new(challenge_params.merge(user: current_user))

    if @challenge.save
      render json: @challenge
    else
      render json: @challenge.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /challenges/1
  def update
    if @challenge.update(challenge_params)
      render json: @challenge
    else
      render json: @challenge.errors, status: :unprocessable_entity
    end
  end

  # DELETE /challenges/1
  def destroy
    @challenge.destroy

    head :no_content
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_challenge
    @challenge = Challenge.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def challenge_params
    params.require(:challenge).permit(
      :spanish_text,
      :english_text,
      :required_streak_for_completion,
      :is_complete
    )
  end
end
