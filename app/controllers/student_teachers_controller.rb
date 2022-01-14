# frozen_string_literal: true

class StudentTeachersController < ApplicationController
  def index
    @student_teachers = policy_scope(StudentTeacher)

    render json: StudentTeacherBlueprint.render(@student_teachers, root: :student_teachers)
  end

  def destroy
    @student_teacher = StudentTeacher.find(params[:id])

    authorize(@student_teacher)

    @student_teacher.destroy

    head :no_content
  end
end
