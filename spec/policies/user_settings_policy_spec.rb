# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSettingsPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  permissions ".scope" do
    it "is empty" do
      expect(Pundit.policy_scope(user.user_settings, UserSettings).ids).to eql([])
    end
  end

  permissions :update? do
    it { is_expected.to permit(user, user.user_settings) }
    it { is_expected.not_to permit(other_user, user.user_settings) }
  end
end
