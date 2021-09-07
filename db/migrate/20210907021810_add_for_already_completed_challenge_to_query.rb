class AddForAlreadyCompletedChallengeToQuery < ActiveRecord::Migration[6.1]
  def change
    add_column :queries, :for_already_completed_challenge, :boolean, null: false, default: false
  end
end
