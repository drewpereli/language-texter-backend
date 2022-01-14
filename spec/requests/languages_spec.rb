# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Languages", type: :request do
  include_context "with authenticated_headers"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "GET index" do
    subject(:get_index) { get "/languages", headers: authenticated_headers }

    let(:response_ids) do
      parsed_body["languages"].map { |record| record["id"] }
    end

    before do
      create_list(:language, 10)
    end

    it "responds with the Language records " do
      get_index
      expect(response_ids).to match_array(Language.ids)
    end
  end
end
