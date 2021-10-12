# frozen_string_literal: true

class TwilioController < ApplicationController
  skip_before_action :ensure_authenticated

  def guess
    unless Question.current_active.present?
      response = Twilio::TwiML::MessagingResponse.new do |r|
        r.message body: "There isn't an active question right now."
      end

      render xml: response.to_s

      return
    end

    Attempt.create_and_process(text: params["Body"], question: Question.current_active)

    head :no_content
  end
end
