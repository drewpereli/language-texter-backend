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

  describe "POST create" do
    subject(:post_create) { post "/users", params: {user: create_params} }

    include_context "with twilio_client stub"

    let(:create_params) do
      {
        username: "foobar",
        phone_number: "+12223334444",
        password: "this-is-my-pretty-alright-password",
        password_confirmation: "this-is-my-pretty-alright-password"
      }
    end

    it "creates a new User with confirmed = false and correct attributes" do
      expect { post_create }.to change(User, :count).by(1)
      user = User.find(parsed_body["user"]["id"])
      expect(user.username).to eql("foobar")
      expect(user.phone_number).to eql("+12223334444")
    end

    it "creates a new user with confirmed = false and a confirmation token" do
      expect { post_create }.to change(User, :count).by(1)
      user = User.find(parsed_body["user"]["id"])
      expect(user.confirmed).to be_falsey
      expect(user.confirmation_token).to be_a(String)
      expect(user.confirmation_token.length).to be >= 24
    end
  end

  describe "login" do
    subject(:post_login) { post "/users/login", params: params }

    let!(:user) do
      create(:user, username: "myusername", password: "this-is-my-pretty-alright-password",
                    password_confirmation: "this-is-my-pretty-alright-password",
                    confirmed: true)
    end

    context "when username and password are correct" do
      let(:params) do
        {username: "myusername", password: "this-is-my-pretty-alright-password"}
      end

      it "responds with a token" do
        post_login
        expect(parsed_body["user"]["id"]).to eql(user.id)
        expect(parsed_body["token"]).to eql(user.jwt_token)
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

    context "when user is not confirmed" do
      let(:params) do
        {username: "myusername", password: "this-is-my-pretty-alright-password"}
      end

      before do
        user.update(confirmed: false)
      end

      it "responds with a 401" do
        post_login
        expect(response.status).to be(401)
      end
    end
  end

  describe "change_password" do
    subject(:post_change_password) { post "/users/change_password", params: params, headers: authenticated_headers }

    let!(:user) do
      create(:user, username: "myusername", password: "this-is-my-pretty-alright-password",
                    password_confirmation: "this-is-my-pretty-alright-password")
    end

    let(:params) do
      {
        old_password: old_password,
        new_password: new_password,
        new_password_confirmation: new_password_confirmation
      }
    end

    let(:old_password) { "this-is-my-pretty-alright-password" }
    let(:new_password) { "this-is-my-new-pretty-alright-password" }
    let(:new_password_confirmation) { "this-is-my-new-pretty-alright-password" }

    context "when params are correct" do
      it "responds with a 204" do
        post_change_password
        expect(response.status).to be(204)
      end

      it "updates the user password" do
        post_change_password
        user.reload
        expect(user.authenticate("this-is-my-new-pretty-alright-password")).to be_truthy
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
        expect(user.authenticate("this-is-my-new-pretty-alright-password")).to be_falsey
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
        expect(user.authenticate("this-is-my-new-pretty-alright-password")).to be_falsey
      end
    end
  end

  describe "POST confirm" do
    subject(:post_confirm) { post "/users/#{user_id}/confirm", params: {confirmation_token: confirmation_token} }

    let!(:user) { create(:user, confirmed: false, confirmation_token: "abc") }
    let(:confirmation_token) { "abc" }
    let(:user_id) { user.id }

    shared_examples "it succeeds" do
      it "responds with a 200" do
        post_confirm
        expect(response.status).to be(200)
      end

      it "confirms the user" do
        post_confirm
        user.reload
        expect(user.confirmed).to be_truthy
      end
    end

    shared_examples "it fails" do
      it "responds with a 404" do
        post_confirm
        expect(response.status).to be(404)
      end

      it "does not confirm the user" do
        post_confirm
        user.reload
        expect(user.confirmed).to be_falsey
      end
    end

    context "when the token is correct" do
      include_examples "it succeeds"
    end

    context "when the token is incorrect" do
      let(:confirmation_token) { "abcdef" }

      include_examples "it fails"
    end

    context "when the user id doesn't exist" do
      let(:user_id) { 9999 }

      include_examples "it fails"
    end

    context "when the user is already confirmed" do
      before do
        user.update!(confirmed: true)
      end

      it "responds with a 404" do
        post_confirm
        expect(response.status).to be(404)
      end
    end
  end
end
