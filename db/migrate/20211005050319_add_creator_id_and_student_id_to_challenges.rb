class AddCreatorIdAndStudentIdToChallenges < ActiveRecord::Migration[6.1]
  def up
    add_column :challenges, :student_id, :integer
    add_index :challenges, :student_id
    add_column :challenges, :creator_id, :integer
    add_index :challenges, :creator_id

    drew = User.find_by(username: "drew")

    Challenge.find_each do |challenge|
      challenge.student_id = drew.id
      challenge.creator_id = drew.id

      challenge.save(validate: false)
    end

    remove_column :challenges, :user_id
    change_column_null :challenges, :student_id, false
    change_column_null :challenges, :creator_id, false
  end

  def down
    add_belongs_to :challenges, :user

    Challenge.find_each do |challenge|
      challenge.user_id = challenge.creator_id
      challenge.save(validate: false)
    end

    remove_column :challenges, :student_id
    remove_column :challenges, :creator_id

    change_column_null :challenges, :user_id, false
  end
end
