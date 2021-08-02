# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "POST /login" do
    let(:login) { post "/login", params: request_params, headers: headers }

    let(:headers) { {"ContentType" => "application/json"} }

    let(:request_params) do
      {username: request_username, password: request_password}
    end

    let(:parsed_body) do
      JSON.parse(response.body)
    end

    context "when username and password are correct" do
      let!(:user) do
        User.create(username: "foobar", phone_number: "1234567890", password: "my-password",
                    password_confirmation: "my-password")
      end
      let(:request_username) { "foobar" }
      let(:request_password) { "my-password" }

      it "responds with a 200" do
        login
        expect(response.status).to be 200
      end

      it "includes a token as a top level key" do
        login
        expect(parsed_body["token"]).not_to be_empty
      end

      it "includes the user with the correct id and username" do
        login
        expect(parsed_body["user"]).to eql({
          "id" => user.id,
          "username" => user.username
        })
      end
    end

    # context "when username is not found" do
    #   let(:user) { create(:user, username: "foobar", password: "my-password") }
    #   let(:request_username) { "not foobar" }
    #   let(:request_password) { "my-password" }
    # end
  end
end
