class AddLanguageToChallenges < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :challenges, :language

    reversible do |dir|
      dir.up do
        Challenge.update_all(language_id: Language.find_by(code: "es").id)
      end
    end

    change_column_null :challenges, :language_id, true
  end
end
