class CreateStudentTeachers < ActiveRecord::Migration[6.1]
  def change
    create_table :student_teachers do |t|
      t.integer :student_id, null: false
      t.integer :teacher_id, null: false
      t.timestamps

      t.index [:student_id, :teacher_id], unique: true
    end
  end
end
