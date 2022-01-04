# frozen_string_literal: true

class LanguagesController < ApplicationController
  skip_before_action :ensure_authenticated, only: %i[index]
  skip_after_action :verify_authorized, only: %i[index]
  
  def index
    @languages = policy_scope(Language)

    render json: LanguageBlueprint.render(@languages, root: :languages)
  end
end
