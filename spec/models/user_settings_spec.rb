# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSettings, type: :model do
  describe "validations" do
    subject(:valid?) { user_settings.valid? }

    let(:user_settings) { user.user_settings }
    let(:user) { create(:user) }

    before do
      user_settings.default_challenge_language_id = default_challenge_language_id
    end

    context "when default_challenge_language_id is nil" do
      let(:default_challenge_language_id) { nil }

      it { is_expected.to be_falsey }
    end

    context "when default_challenge_language_id is valid" do
      let(:default_challenge_language_id) { language.id }
      let(:language) { create(:language) }

      it { is_expected.to be_truthy }
    end

    context "when default_challenge_language_id is not valid" do
      let(:default_challenge_language_id) { 99_999_999 }

      it { is_expected.to be_falsey }
    end
  end
end
