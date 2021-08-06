# frozen_string_literal: true

class Inquisitor
  class << self
    # runs every minute
    def send_query_if_time
      send_query if time_for_query?
    end

    def send_query
      if last_query.nil? || last_query.attempt
        # create a new query
        challenge = Challenge.incomplete.sample
        user = User.find_by(username: "drew")
        language = %w[spanish english].sample

        query = Query.create(challenge: challenge, user: user, language: language)

        query.send_message
      else
        last_query.resend_message
      end
    end

    def time_for_query?
      current_hour = current_time.strftime("%H").to_i

      return false if current_hour < 8 || current_hour > 22

      return true if last_query.nil?

      seconds_since_last_query = current_time - last_query.created_at.in_time_zone("US/Pacific")

      return true if last_query.attempt.nil? && seconds_since_last_query > 3600

      rand > 0.99
    end

    def current_time
      Time.now.in_time_zone("US/Pacific")
    end

    def last_query
      Query.last
    end
  end
end
