class RenameTableQueryToQuestion < ActiveRecord::Migration[6.1]
  def change
    rename_table :queries, :questions
    rename_column :attempts, :question_id, :question_id
  end
end
