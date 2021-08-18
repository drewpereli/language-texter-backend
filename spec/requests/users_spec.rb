# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  include_context "with authenticated_headers"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "GET index" do
    subject(:get_index) { get "/users", headers: authenticated_headers }

    let(:response_ids) do
      parsed_body["users"].map { |record| record["id"] }
    end

    before do
      create_list(:user, 10)
    end

    it "responds with the User records " do
      get_index
      expect(response_ids).to match_array(User.ids)
    end
  end

  describe "login" do
    subject(:post_login) { post "/login", params: params }

    let!(:user) { create(:user, username: "myusername", password: "mypassword", password_confirmation: "mypassword") }

    context "when username and password are correct" do
      let(:params) do
        {username: "myusername", password: "mypassword"}
      end

      it "responds with a token" do
        post_login
        expect(parsed_body["user"]["id"]).to eql(user.id)
        expect(parsed_body["token"]).to eql(user.token)
      end
    end

    context "when username is valid but password is incorrect" do
      let(:params) do
        {username: "myusername", password: "wrong password"}
      end

      it "responds with a 401" do
        post_login
        expect(response.status).to be(401)
      end
    end

    context "when username is invalid" do
      let(:params) do
        {username: "wrong username", password: "wrong password"}
      end

      it "responds with a 401" do
        post_login
        expect(response.status).to be(401)
      end
    end

    context "when username is blank" do
      let(:params) do
        {password: "wrong password"}
      end

      it "responds with a 401" do
        post_login
        expect(response.status).to be(401)
      end
    end

    context "when password is blank" do
      let(:params) do
        {username: "myusername"}
      end

      it "responds with a 401" do
        post_login
        expect(response.status).to be(401)
      end
    end
  end

  describe "change_password" do
    subject(:post_change_password) { post "/change_password", params: params, headers: authenticated_headers }

    let!(:user) { create(:user, username: "myusername", password: "mypassword", password_confirmation: "mypassword") }

    let(:params) do
      {
        old_password: old_password,
        new_password: new_password,
        new_password_confirmation: new_password_confirmation
      }
    end

    let(:old_password) { "mypassword" }
    let(:new_password) { "mynewpassword" }
    let(:new_password_confirmation) { "mynewpassword" }

    context "when params are correct" do
      it "responds with a 204" do
        post_change_password
        expect(response.status).to be(204)
      end

      it "updates the user password" do
        post_change_password
        user.reload
        expect(user.authenticate("mynewpassword")).to be_truthy
      end
    end

    context "when old password is incorrect" do
      let(:old_password) { "wrong" }

      it "responds with a 401" do
        post_change_password
        expect(response.status).to be(401)
      end

      it "doesn't update the user password" do
        post_change_password
        user.reload
        expect(user.authenticate("mynewpassword")).to be_falsey
      end
    end

    context "when passwords don't match" do
      let(:new_password_confirmation) { "wrong" }

      it "responds with a 401" do
        post_change_password
        expect(response.status).to be(401)
      end

      it "doesn't update the user password" do
        post_change_password
        user.reload
        expect(user.authenticate("mynewpassword")).to be_falsey
      end
    end
  end
end
