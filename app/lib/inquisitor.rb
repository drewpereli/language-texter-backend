# frozen_string_literal: true

class Inquisitor
  class << self
    # runs every minute
    def send_text_if_time
      return unless appropriate_time_for_text?

      if last_query_waiting_on_attempt?
        send_reminder_if_time
      elsif rand < 0.1
        send_new_query
      end
    end

    def send_new_query
      # 10% to send complete challenge
      challenge = if rand < 0.1
                    Challenge.random_complete
                  else
                    Challenge.random_active_not_last
                  end

      challenge.create_and_process
    end

    def send_reminder_if_time
      last_query.resend_message if last_query.time_since_last_sent >= 1.hour
    end

    def last_query_waiting_on_attempt?
      last_query.attempt.nil?
    end

    def last_query
      Query.last
    end

    def appropriate_time_for_text?
      current_hour >= 8 && current_hour < 23
    end

    def current_hour
      current_time.strftime("%H").to_i
    end

    def current_time
      Time.now.in_time_zone("US/Pacific")
    end
  end
end
