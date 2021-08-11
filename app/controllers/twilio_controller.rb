# frozen_string_literal: true

class TwilioController < ApplicationController
  skip_before_action :ensure_authenticated

  def guess
    response = Twilio::TwiML::MessagingResponse.new do |r|
      r.message body: message
    end

    last_query.challenge.update(is_complete: true) if last_query&.challenge&.streak_enough_for_completion?

    render xml: response.to_s
  end

  private

  def message
    if !last_query
      "There are no queries yet."
    elsif last_query.attempt
      "There isn't an active query right now."
    else
      attempt = Attempt.create(query: last_query, text: params["Body"])
      attempt.response_message
    end
  end

  def last_query
    Query.last
  end
end
