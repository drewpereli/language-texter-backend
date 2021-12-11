# frozen_string_literal: true

class LanguagesController < ApplicationController
  def index
    @languages = policy_scope(Language)

    render json: LanguageBlueprint.render(@languages, root: :languages)
  end
end
