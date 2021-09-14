class MakeQueriesChallengeColumnNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :queries, :challenge_id, true
  end
end
