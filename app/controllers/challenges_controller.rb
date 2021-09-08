# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :set_challenge, only: %i[show update destroy]

  # GET /challenges/1
  def show
    render json: @challenge
  end

  # GET /challenges
  def index
    return render json: {errors: "must specify a status"} unless params[:status]

    @challenges = Challenge
                  .where(status: params[:status])
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(params[:per_page])

    render json: @challenges, meta: {total_pages: @challenges.total_pages}
  end

  # POST /challenges
  def create
    @challenge = Challenge.create_and_process(challenge_params.merge(user: current_user))

    if @challenge.valid?
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
      :required_streak_for_completion
    )
  end
end
