class AddLastSentAtToQueries < ActiveRecord::Migration[6.1]
  def change
    add_column :queries, :last_sent_at, :datetime
  end
end
