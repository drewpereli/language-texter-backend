# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentTeacherPolicy, type: :policy do
  subject { described_class }

  let!(:u1) { create(:user) }
  let!(:u2) { create(:user) }
  let!(:u3) { create(:user) }
  let!(:u4) { create(:user) }

  let!(:st1) { create(:student_teacher, student: u1, teacher: u2) }
  let!(:st2) { create(:student_teacher, student: u2, teacher: u3) }
  let!(:st3) { create(:student_teacher, student: u3, teacher: u1) }
  let!(:st4) { create(:student_teacher, student: u4, teacher: u3) }

  permissions ".scope" do
    it "includes all where the user is either the student or the teacher" do
      expect(Pundit.policy_scope(u1, StudentTeacher).ids).to match_array([st1.id, st3.id])
    end
  end

  permissions :destroy? do
    it "can be destroyed by the teacher" do
      expect(described_class).to permit(u1, st1)
    end

    it "can be destroyed by the student" do
      expect(described_class).to permit(u2, st1)
    end

    it "can't be destroyed by a non-creator or non-student" do
      expect(described_class).not_to permit(u3, st1)
    end
  end
end
