# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentTeacherInvitation, type: :model do
  describe "#valid?" do
    context "when recipient phone number is invalid" do
      let(:invitation) { build(:student_teacher_invitation) }

      before { invitation.recipient_phone_number = "abc" }

      it "is false" do
        expect(invitation).not_to be_valid
      end
    end

    context "when user has already sent the weekly limit" do
      let(:invitation) { build(:student_teacher_invitation, creator: user) }

      let(:user) { create(:user) }

      before do
        create_list(:student_teacher_invitation, described_class::WEEKLY_INVITE_LIMIT, creator: user,
                                                                                       created_at: 2.days.ago)
      end

      it "is false" do
        expect(invitation).not_to be_valid
      end
    end

    context "when recipient phone number is the same as creator phone number" do
      let(:invitation) { build(:student_teacher_invitation, creator: user, recipient_phone_number: "(222)-333-4444") }

      let(:user) { create(:user, phone_number: "2223334444") }

      it "is false" do
        expect(invitation).not_to be_valid
      end
    end
  end

  describe ".create_and_send" do
    subject(:create_and_send) { described_class.create_and_send(params) }

    include_context "with twilio_client stub"

    let(:user) { create(:user, username: "luther manhole") }

    let(:params) do
      {
        creator: user,
        recipient_name: "my recipient",
        recipient_phone_number: "333-444-5555",
        requested_role: "teacher"
      }
    end

    it "creates a StudentTeacherInvitation model" do
      expect { create_and_send }.to change(described_class, :count).by(1)
    end

    it "texts the recipient" do
      create_and_send
      expect(twilio_client).to have_received(:text_number)
                                 .with("+13334445555",
                                       /^Hey there! luther manhole has invited you to be their teacher at/)
    end
  end

  describe "#respond_and_notify" do
    subject(:respond_and_notify) { invitation.respond_and_notify(status) }

    include_context "with twilio_client stub"

    let(:invitation) do
      create(:student_teacher_invitation, creator: u1, recipient: u2, recipient_name: "Chaplin Crabtree")
    end

    let(:u1) { create(:user) }
    let(:u2) { create(:user, username: "Chaplin Crabtree") }

    context "when the invite is accepted" do
      let(:status) { "accepted" }

      it "updates the invitation with the passed-in status" do
        respond_and_notify
        invitation.reload
        expect(invitation).to be_accepted
      end

      it "texts the creator the 'accepted' message" do
        respond_and_notify
        expect(twilio_client).to have_received(:text_number).with(invitation.creator.phone_number,
                                                                  "Chaplin Crabtree accepted your invitation!")
      end

      it "creates a student-teacher record" do
        expect { respond_and_notify }.to change(StudentTeacher, :count).by(1)
      end
    end

    context "when the invite is rejected" do
      let(:status) { "rejected" }

      it "updates the invitation with the passed-in status" do
        respond_and_notify
        invitation.reload
        expect(invitation).to be_rejected
      end

      it "texts the creator the 'rejected' message" do
        respond_and_notify
        expect(twilio_client).to have_received(:text_number).with(invitation.creator.phone_number,
                                                                  "Chaplin Crabtree rejected your invitation.")
      end

      it "does not create a student-teacher record" do
        expect { respond_and_notify }.to change(StudentTeacher, :count).by(0)
      end
    end

    context "when the status is something random" do
      let(:status) { "asdfasdfasdfasdf" }

      it "does not update the invitation with the passed-in status" do
        respond_and_notify
        invitation.reload
        expect(invitation).to be_sent
      end

      it "does not text the creator" do
        respond_and_notify
        expect(twilio_client).not_to have_received(:text_number)
      end

      it "does not create a student-teacher record" do
        expect { respond_and_notify }.to change(StudentTeacher, :count).by(0)
      end
    end
  end
end
