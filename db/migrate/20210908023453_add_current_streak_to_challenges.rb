class AddCurrentStreakToChallenges < ActiveRecord::Migration[6.1]
  def up
    add_column :challenges, :current_streak, :integer, null: false, default: 0

    Challenge.find_each do |challenge|
      current_streak = current_streak_for_challenge(challenge)
      challenge.update(current_streak: current_streak)
    end
  end

  def down
    remove_column :challenges, :current_streak
  end

  def current_streak_for_challenge(challenge)
    if challenge.complete?
      return challenge.required_streak_for_completion
    end

    recent_attempts = challenge.attempts.order("attempts.created_at DESC").limit(challenge.required_streak_for_completion)

    count = 0

    recent_attempts.each do |attempt|
      break unless attempt.correct?

      count += 1
    end

    count
  end
end
