# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#valid?" do
    context "when some required fields are missing" do
      shared_examples "field is required" do |params|
        let(:user) { create(:user) }

        before do
          user[params[:field]] = nil
        end

        it "is false when #{params[:field]} is nil" do
          expect(user).not_to be_valid
        end
      end

      required_fields = %i[
        username
        phone_number
        password_digest
      ]

      required_fields.each do |field|
        include_examples "field is required", {field: field}
      end
    end

    context "when all required fields are present" do
      let(:user) { create(:user) }

      it "is true" do
        expect(user).to be_valid
      end
    end

    context "when trying to create a user with a username that's been taken already" do
      let!(:old_user) { create(:user, username: "foo") }
      let(:user) { create(:user, username: "other") }

      before do
        user.username = "foo"
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end
  end
end
