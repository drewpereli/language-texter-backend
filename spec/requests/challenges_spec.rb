# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenges", type: :request do
  include_context "with authenticated_headers"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "GET index" do
    subject(:get_index) { get "/challenges", params: {status: "queued"}, headers: authenticated_headers }

    let(:response_ids) do
      parsed_body["challenges"].map { |record| record["id"] }
    end

    before do
      create_list(:challenge, 10, status: :queued, student: user)
    end

    it "responds with the Challenge records " do
      get_index
      expect(response_ids).to match_array(Challenge.ids)
    end
  end

  describe "GET show" do
    subject(:get_show) { get "/challenges/#{challenge.id}", headers: authenticated_headers }

    let!(:challenge) { create(:challenge, student: user) }

    it "gets the requested Challenge" do
      get_show

      expect(parsed_body["challenge"]["id"]).to eql(challenge.id)
    end
  end

  describe "POST create" do
    subject(:post_create) { post "/challenges", params: {challenge: create_params}, headers: authenticated_headers }

    include_context "with twilio_client stub"

    let(:student) { create(:user) }

    let(:create_params) do
      {
        learning_language_text: "amigo",
        native_language_text: "friend",
        student_id: student.id,
        required_score: 20
      }
    end

    it "creates a new Challenge" do
      expect { post_create }.to change(Challenge, :count).by(1)
    end

    context "when student is not included" do
      let(:create_params) do
        {
          learning_language_text: "amigo",
          native_language_text: "friend",
          student_id: nil,
          required_score: 20
        }
      end

      it "creates a new Challenge" do
        expect { post_create }.to change(Challenge, :count).by(1)
      end
    end
  end

  describe "PUT update" do
    subject(:put_update) do
      put "/challenges/#{challenge.id}",
          params: {challenge: update_params},
          headers: authenticated_headers
    end

    let!(:challenge) { create(:challenge, creator: user) }

    let(:update_params) do
      {learning_language_text: "my changed val"}
    end

    it "updates the requested Challenge" do
      put_update
      challenge.reload
      expect(challenge.learning_language_text).to eql("my changed val")
    end
  end

  describe "DELETE destroy" do
    subject(:delete_destroy) { delete "/challenges/#{challenge.id}", headers: authenticated_headers }

    let!(:challenge) { create(:challenge, creator: user) }

    it "destroys the requested Challenge" do
      expect { delete_destroy }.to change(Challenge, :count).by(-1)
    end
  end
end
