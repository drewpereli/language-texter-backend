# frozen_string_literal: true

class TwilioController < ApplicationController
  skip_before_action :ensure_authenticated
  skip_after_action :verify_authorized

  def guess
    normalized_from_number = PhonyRails.normalize_number(params["From"], default_country_code: "US")
    user = User.find_by(phone_number: normalized_from_number)

    return unless user.present?

    unless user.active_question.present?
      response = Twilio::TwiML::MessagingResponse.new do |r|
        r.message body: "There isn't an active question right now."
      end

      render xml: response.to_s

      return
    end

    Attempt.create_and_process(text: params["Body"], question: user.active_question)

    head :no_content
  end
end
