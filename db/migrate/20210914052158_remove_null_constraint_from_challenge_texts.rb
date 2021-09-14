class RemoveNullConstraintFromChallengeTexts < ActiveRecord::Migration[6.1]
  def change
    change_column_null :challenges, :spanish_text, true
    change_column_null :challenges, :english_text, true
  end
end
