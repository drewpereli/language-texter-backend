# frozen_string_literal: true

class UserSettingsController < ApplicationController
  before_action :set_user_settings, only: %i[update]

  def update
    authorize(@user_settings)

    if @user_settings.update(user_settings_params)
      render json: UserSettingsBlueprint.render(@user_settings, root: :user_settings)
    else
      render_model_errors(@user_settings)
    end
  end

  private

  def set_user_settings
    @user_settings = UserSettings.find(params[:id])
  end

  def user_settings_params
    params.require(:user_settings).permit(
      :timezone,
      :default_challenge_language_id,
      :earliest_text_time,
      :latest_text_time,
      :question_frequency,
      :reminder_frequency
    )
  end
end
