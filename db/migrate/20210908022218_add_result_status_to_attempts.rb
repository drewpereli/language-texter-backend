class AddResultStatusToAttempts < ActiveRecord::Migration[6.1]
  def change
    add_column :attempts, :result_status, :integer # enum
  end
end
