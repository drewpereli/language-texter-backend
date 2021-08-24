class ConvertChallengeCompletionSystemToStatuses < ActiveRecord::Migration[6.1]
  def up
    add_column :challenges, :status, :integer, null: false, default: 0 # enum column

    Challenge.find_each do |challenge|
      if challenge.is_complete
        challenge.update(status: "complete")
      else
        challenge.update(status: "active")
      end
    end

    remove_column :challenges, :is_complete
  end

  def down
    add_column :challenges, :is_complete, :boolean, null: false, default: false

    Challenge.find_each do |challenge|
      if challenge.complete?
        challenge.update(is_complete: "complete")
      end
    end

    remove_column :challenges, :status
  end
end
