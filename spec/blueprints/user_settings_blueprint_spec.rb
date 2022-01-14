# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSettingsBlueprint do
  let(:serialized) { JSON.parse(described_class.render(user_settings)) }

  let(:user) { create(:user) }
  let(:user_settings) { user.user_settings }

  let(:serialized_default_challenge_language_id) { serialized["default_challenge_language_id"] }

  let(:language) { create(:language) }

  before do
    user_settings.update(default_challenge_language: language)
  end

  it "includes default_challenge_language_id in the serialized hash" do
    expect(serialized_default_challenge_language_id).not_to be_nil
    expect(serialized_default_challenge_language_id).to eql(language.id)
  end
end
