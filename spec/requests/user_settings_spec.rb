# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserSettings", type: :request do
  include_context "with authenticated_headers"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "PUT update" do
    subject(:put_update) do
      put "/user_settings/#{user_settings.id}",
          params: {user_settings: update_params},
          headers: authenticated_headers
    end

    let!(:user_settings) { user.user_settings }

    let(:update_params) do
      {timezone: "US/Lost_Angeles"}
    end

    it "updates the requested UserSettings" do
      put_update
      user_settings.reload
      expect(user_settings.timezone).to eql("US/Lost_Angeles")
    end
  end
end
