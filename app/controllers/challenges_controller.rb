# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :set_challenge, only: %i[show update destroy]

  # GET /challenges/1
  def show
    authorize(@challenge)

    render json: ChallengeBlueprint.render(@challenge, root: :challenge)
  end

  # GET /challenges
  def index
    return render json: {errors: "must specify a status"} unless params[:status]

    @challenges = policy_scope(Challenge)
                    .where(status: params[:status])
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(params[:per_page])

    render json: ChallengeBlueprint.render(@challenges, root: :challenges, meta: {total_pages: @challenges.total_pages})
  end

  # POST /challenges
  def create
    authorize(Challenge)

    student_id = challenge_params[:student_id].present? ? challenge_params[:student_id] : current_user.id

    params_with_defaults = challenge_params.merge(creator: current_user,
                                                  student_id: student_id)

    @challenge = Challenge.create_and_process(params_with_defaults)

    if @challenge.valid?
      render json: ChallengeBlueprint.render(@challenge, root: :challenge)
    else
      render_model_errors(@challenge)
    end
  end

  # PATCH/PUT /challenges/1
  def update
    authorize(@challenge)

    if @challenge.update(challenge_params)
      render json: ChallengeBlueprint.render(@challenge, root: :challenge)
    else
      render_model_errors(@challenge)
    end
  end

  # DELETE /challenges/1
  def destroy
    authorize(@challenge)

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
      :learning_language_text,
      :native_language_text,
      :learning_language_text_note,
      :native_language_text_note,
      :required_score,
      :student_id,
      :language_id
    )
  end
end
