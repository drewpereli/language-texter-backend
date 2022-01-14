# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChallengePolicy, type: :policy do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:user4) { create(:user) }

  let!(:c1) { create(:challenge, creator: user1, student: user2) }
  let!(:c2) { create(:challenge, creator: user2, student: user1) }
  let!(:c3) { create(:challenge, creator: user3, student: user3) }

  permissions ".scope" do
    it "includes all where the user is either the creator or the student" do
      expect(Pundit.policy_scope(user1, Challenge).ids).to match_array([c1.id, c2.id])
    end
  end

  permissions :create? do
    it "can be created by any user" do
      expect(described_class).to permit(user4)
    end
  end

  permissions :show? do
    it "can be seen by the creator" do
      expect(described_class).to permit(user1, c1)
    end

    it "can be seen by the student" do
      expect(described_class).to permit(user2, c1)
    end

    it "can't be seen by a non-creator or non-student" do
      expect(described_class).not_to permit(user3, c1)
    end
  end

  permissions :update?, :destroy? do
    it "can be updated/deleted by the creator" do
      expect(described_class).to permit(user1, c1)
    end

    it "can't be updated/deleted by the student" do
      expect(described_class).not_to permit(user2, c1)
    end

    it "can't be updated/deleted by a non-creator or non-student" do
      expect(described_class).not_to permit(user3, c1)
    end
  end
end
