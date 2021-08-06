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
        query = Query.create(challenge: random_incomplete_challenge_not_last, user: user_drew,
                             language: random_language)
        query.send_message
      else
        last_query.resend_message
      end
    end

    def user_drew
      User.find_by(username: "drew")
    end

    def random_language
      if rand < 0.66
        "english"
      else
        "spanish"
      end
    end

    def random_incomplete_challenge_not_last
      if last_query.nil?
        Challenge.incomplete.sample
      else
        Challenge.incomplete.where.not(id: last_query.challenge_id).sample
      end
    end

    def time_for_query?
      current_hour = current_time.strftime("%H").to_i

      return false if current_hour < 8 || current_hour > 23

      return true if last_query.nil?

      seconds_since_last_query = current_time - last_query.last_sent_at.in_time_zone("US/Pacific")

      return true if last_query.attempt.nil? && seconds_since_last_query > 3600

      rand < 0.1
    end

    def current_time
      Time.now.in_time_zone("US/Pacific")
    end

    def last_query
      Query.last
    end
  end
end
