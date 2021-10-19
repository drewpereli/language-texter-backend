class CreateStudentTeacherInvitations < ActiveRecord::Migration[6.1]
  def change
    create_table :student_teacher_invitations do |t|
      t.integer :creator_id, null: false
      t.string :recipient_name, null: false
      t.string :recipient_phone_number, null: false
      t.integer :requested_role, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
