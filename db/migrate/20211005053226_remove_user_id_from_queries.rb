class RemoveUserIdFromQueries < ActiveRecord::Migration[6.1]
  def change
    remove_column :queries, :user_id, :integer
  end
end
