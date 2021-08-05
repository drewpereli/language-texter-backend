# frozen_string_literal: true

class TwilioController < ApplicationController
  skip_before_action :ensure_authenticated

  def guess
    message = if !last_query
                "There are no queries yet"
              elsif last_query.attempt
                "You already responded to this one"
              else
                attempt = Attempt.create(query: last_query, text: params["Body"])

                if attempt.correct?
                  streak_count = last_query.challenge.streak_count
                  required_streak = last_query.challenge.required_streak_for_completion

                  correct_attempts_still_required = [0, required_streak - streak_count].max

                  case correct_attempts_still_required
                  when 0
                    "Good job, that's correct! You've completed this challenge!"
                  when 1
                    "Good job, that's correct! You only need 1 more correct guess to complete this challenge!"
                  else
                    "Good job, that's correct! #{correct_attempts_still_required} more correct guesses in a row needed to complete this challenge."
                  end

                else
                  "Wrong. The correct answer is '#{last_query.correct_text}'."
                end
              end

    response = Twilio::TwiML::MessagingResponse.new do |r|
      r.message body: message
    end

    render xml: response.to_s
  end

  def last_query
    Query.last
  end
end
