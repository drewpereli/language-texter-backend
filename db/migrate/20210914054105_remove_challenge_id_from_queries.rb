class RemoveChallengeIdFromQueries < ActiveRecord::Migration[6.1]
  def change
    remove_belongs_to :queries, :challenge
  end
end
