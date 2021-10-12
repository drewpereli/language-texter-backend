# frozen_string_literal: true

class Inquisitor
  class << self
    # runs every minute
    def send_text_if_time
      return unless appropriate_time_for_text?

      if last_question_waiting_on_attempt?
        send_reminder_if_time
      elsif rand < 0.1
        send_new_question
      end
    end

    def send_new_question
      # 10% to send complete challenge
      challenge = if rand < 0.1
                    Challenge.random_complete
                  else
                    Challenge.random_active_not_last
                  end

      challenge.create_and_process
    end

    def send_reminder_if_time
      last_question.resend_message if last_question.time_since_last_sent >= 1.hour
    end

    def last_question_waiting_on_attempt?
      !last_question.attempted?
    end

    def last_question
      Question.last
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
