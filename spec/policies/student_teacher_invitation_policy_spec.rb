# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentTeacherInvitationPolicy, type: :policy do
  subject { described_class }

  permissions ".scope" do
    let!(:u1) { create(:user) }
    let!(:u2) { create(:user) }
    let!(:u3) { create(:user) }
    let!(:u4) { create(:user) }

    let!(:st1) { create(:student_teacher_invitation, creator: u1, recipient: u2) }
    let!(:st2) { create(:student_teacher_invitation, creator: u2, recipient: u3) }
    let!(:st3) { create(:student_teacher_invitation, creator: u3, recipient: u1) }
    let!(:st4) { create(:student_teacher_invitation, creator: u4, recipient: u3) }
    let!(:st5) { create(:student_teacher_invitation, creator: u4, recipient_phone_number: u1.phone_number) }

    it "includes all where the user is either the sender or the recipient" do
      expect(Pundit.policy_scope(u1, StudentTeacherInvitation).ids).to match_array([st1.id, st3.id, st5.id])
    end
  end

  permissions :create?, :destroy? do
    let!(:u1) { create(:user) }
    let!(:u2) { create(:user) }
    let!(:u3) { create(:user) }

    it "can be created/destroyed if creator is current_user" do
      expect(described_class).to permit(u1, StudentTeacherInvitation.new(creator: u1, recipient: u2))
    end

    it "cannot be created/destroyed unless creator is current_user" do
      expect(described_class).not_to permit(u1, StudentTeacherInvitation.new(creator: u2, recipient: u3))
    end
  end

  permissions :update? do
    let!(:u1) { create(:user) }
    let!(:u2) { create(:user) }
    let!(:u3) { create(:user) }

    it "can be updated if recipient is current_user" do
      expect(described_class).to permit(u2, StudentTeacherInvitation.new(creator: u1, recipient: u2))
    end

    it "cannot be updated unless recipient is current_user" do
      expect(described_class).not_to permit(u1, StudentTeacherInvitation.new(creator: u2, recipient: u3))
    end
  end
end
