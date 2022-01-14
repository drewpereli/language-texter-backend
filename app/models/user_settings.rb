# frozen_string_literal: true

class UserSettings < ApplicationRecord
  self.table_name = "user_settings"

  belongs_to :user
  belongs_to :default_challenge_language, class_name: "Language", optional: true

  validates :timezone, :user, :default_challenge_language, :earliest_text_time, :latest_text_time,
            :question_frequency, :reminder_frequency, presence: true

  validates_uniqueness_of :user_id

  enum question_frequency: %i[hourly_questions questions_every_two_hours questions_every_four_hours
                              questions_every_eight_hours daily_questions]
  enum reminder_frequency: %i[no_reminders hourly_reminders reminders_every_four_hours daily_reminders]

  def numeric_text_times
    {
      earliest: {hour: earliest_text_time.split(":")[0].to_i, minute: earliest_text_time.split(":")[1].to_i},
      latest: {hour: latest_text_time.split(":")[0].to_i, minute: latest_text_time.split(":")[1].to_i}
    }
  end
end
