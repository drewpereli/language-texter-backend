# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attempts", type: :request do
  include_context "with authenticated_headers"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "GET index" do
    subject(:get_index) { get "/attempts", params: params, headers: authenticated_headers }

    let(:response_ids) do
      parsed_body["attempts"].map { |record| record["id"] }
    end

    let(:params) { {} }

    let(:challenge_1) { create(:challenge, student: user) }
    let(:challenge_2) { create(:challenge, creator: user) }

    let!(:challenge_1_questions) { create_list(:question, 5, challenge: challenge_1) }
    let!(:challenge_2_questions) { create_list(:question, 5, challenge: challenge_2) }

    before do
      Question.all.each do |question|
        create(:attempt, question: question)
      end
    end

    context "when challenge_id is set" do
      let(:params) do
        {challenge_id: challenge_2.id}
      end

      it "responds with the Attempt for the challenge " do
        get_index
        expect(response_ids).to match_array(challenge_2.questions.map(&:attempt).map(&:id))
        expect(response_ids.length).to be(5)
      end
    end

    context "when challenge_id is empty" do
      it "responds with a 404" do
        get_index
        expect(response.status).to be(404)
      end
    end
  end
end
