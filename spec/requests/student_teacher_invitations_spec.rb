# frozen_string_literal: true

require "rails_helper"

RSpec.describe "StudentTeacherInvitations", type: :request do
  include_context "with authenticated_headers"
  include_context "with twilio_client stub"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "GET index" do
    subject(:get_index) { get "/student_teacher_invitations", headers: authenticated_headers }

    let(:response_ids) do
      parsed_body["student_teacher_invitations"].map { |record| record["id"] }
    end

    before do
      create(:student_teacher_invitation, creator: user)
      create(:student_teacher_invitation, recipient: user)
    end

    it "responds with the StudentTeacherInvitation records " do
      get_index
      expect(response_ids).to match_array(StudentTeacherInvitation.ids)
    end
  end

  describe "POST create" do
    subject(:post_create) do
      post "/student_teacher_invitations", params: {student_teacher_invitation: create_params},
                                           headers: authenticated_headers
    end

    let(:create_params) do
      {
        recipient_name: "Down and Dirty Rufus",
        recipient_phone_number: "888-333-4444",
        requested_role: "student"
      }
    end

    it "creates a new StudentTeacherInvitation" do
      expect { post_create }.to change(StudentTeacherInvitation, :count).by(1)
    end

    it "texts the recipient" do
      post_create
      expect(twilio_client).to have_received(:text_number).with("+18883334444", String)
    end
  end

  describe "PUT update" do
    subject(:put_update) do
      put "/student_teacher_invitations/#{student_teacher_invitation.id}",
          params: {student_teacher_invitation: update_params},
          headers: authenticated_headers
    end

    include_context "with twilio_client stub"

    let!(:student_teacher_invitation) { create(:student_teacher_invitation, recipient: user) }

    let(:update_params) do
      {status: "rejected"}
    end

    it "updates the requested StudentTeacherInvitation" do
      put_update
      student_teacher_invitation.reload
      expect(student_teacher_invitation).to be_rejected
    end

    it "texts the creator" do
      put_update
      expect(twilio_client).to have_received(:text_number).with(student_teacher_invitation.creator.phone_number, String)
    end
  end

  describe "DELETE destroy" do
    subject(:delete_destroy) do
      delete "/student_teacher_invitations/#{student_teacher_invitation.id}", headers: authenticated_headers
    end

    let!(:student_teacher_invitation) { create(:student_teacher_invitation, creator: user) }

    it "destroys the requested StudentTeacherInvitation" do
      expect { delete_destroy }.to change(StudentTeacherInvitation, :count).by(-1)
    end
  end
end
