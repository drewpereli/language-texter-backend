# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttemptsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/attempts").to route_to("attempts#index")
    end
  end
end
