# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#valid?" do
    context "when all required fields are present" do
      let(:user) { create(:user) }

      it "is true" do
        expect(user).to be_valid
      end
    end

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

    context "when password is empty on a new model" do
      let(:user) { build(:user) }

      before do
        user.password = nil
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when password is less than 12 characters long on a new model" do
      let(:user) { build(:user) }

      before do
        user.password = "this-is-bad"
        user.password_confirmation = "this-is-bad"
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when password_confirmation is empty on a new model" do
      let(:user) { build(:user) }

      before do
        user.password_confirmation = nil
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when password doesn't match password confirmation" do
      let(:user) { create(:user) }

      before do
        user.password = "foo"
        user.password_confirmation = "bar"
      end

      it "is false" do
        expect(user).not_to be_valid
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

    context "when phone number is invalid" do
      let(:user) { create(:user) }

      before { user.phone_number = "abc" }

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when updating user attrs besides password" do
      let(:user) { create(:user) }

      before do
        user.update(username: "my new username")
      end

      it "is true" do
        expect(user).to be_valid
      end
    end

    context "when updating password to something invalid" do
      let(:user) { create(:user) }

      before do
        user.update(password: "a", password_confirmation: "a")
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end
  end

  describe ".save" do
    let(:user) { create(:user) }

    before do
      user.phone_number = "222-333-4444"
      user.save
      user.reload
    end

    it "normalizes the phone number before saving" do
      expect(user.phone_number).to eql("+12223334444")
    end
  end
end
