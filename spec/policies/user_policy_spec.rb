# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:user) { create(:user, id: 1) }

  permissions ".scope" do
    subject(:scope_users) { Pundit.policy_scope(user, User) }

    let!(:teacher) { create(:user, id: 2) }
    let!(:teacher_teacher) { create(:user, id: 3) }
    let!(:student) { create(:user, id: 4) }
    let!(:student_student) { create(:user, id: 5) }
    let!(:student_other_teacher) { create(:user, id: 6) }
    let!(:teacher_invite_to) { create(:user, id: 7) }
    let!(:student_invite_to) { create(:user, id: 8) }
    let!(:teacher_invite_from) { create(:user, id: 9) }
    let!(:student_invite_from) { create(:user, id: 10) }
    let!(:unrelated_1) { create(:user, id: 11) }
    let!(:unrelated_2) { create(:user, id: 12) }

    before do
      create(:student_teacher, student: user, teacher: teacher)
      create(:student_teacher, student: teacher, teacher: teacher_teacher)
      create(:student_teacher, student: student, teacher: user)
      create(:student_teacher, student: student_student, teacher: student)
      create(:student_teacher, student: student, teacher: student_other_teacher)

      create(:student_teacher_invitation, creator: user, recipient: teacher_invite_to, requested_role: "teacher")
      create(:student_teacher_invitation, creator: user, recipient: student_invite_to, requested_role: "student")
      create(:student_teacher_invitation, creator: teacher_invite_from, recipient: user, requested_role: "teacher")
      create(:student_teacher_invitation, creator: student_invite_from, recipient: user, requested_role: "student")

      create(:student_teacher, student: unrelated_1, teacher: teacher)
      create(:student_teacher_invitation, creator: unrelated_2, recipient: student, requested_role: "student")
    end

    it "returns the current user and the user with related invites and student-teacher relationships" do
      expect(scope_users.ids).to match_array([
        user.id,
        teacher.id,
        student.id,
        teacher_invite_from.id,
        student_invite_from.id
      ])
    end
  end
end
