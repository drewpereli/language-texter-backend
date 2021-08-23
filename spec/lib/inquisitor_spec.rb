# frozen_string_literal: true

require "rails_helper"

RSpec.describe Inquisitor do
  describe ".time_for_query?" do
    subject { described_class.time_for_query? }

    let(:time_now) { Time.find_zone("US/Pacific").local(2000, 1, 1, hour_now, minute_now, 0) }
    let(:hour_now) { 12 }
    let(:minute_now) { 0 }

    before do
      allow(Time).to receive(:now).and_return(time_now)
    end

    it "works" do
      expect(Time.now.strftime("%H").to_i).to be 12
      expect(Time.now.strftime("%M").to_i).to be 0
    end

    context "when it's before 8 AM" do
      let(:hour_now) { 3 }

      it { is_expected.to be_falsey }
    end

    context "when it's after 11 PM" do
      let(:hour_now) { 23 }
      let(:minute_now) { 1 }

      it { is_expected.to be_falsey }
    end

    context "when there are no queries in the db" do
      it { is_expected.to be_truthy }
    end

    context "when the last query was sent over an hour ago" do
      let!(:query) { create(:query, created_at: 3.hours.ago, last_sent_at: 2.hours.ago) }

      it { is_expected.to be_truthy }
    end

    context "when the last query was sent less than an hour ago" do
      let!(:query) { create(:query, created_at: 3.hours.ago, last_sent_at: 50.minutes.ago) }

      it { is_expected.to be_falsey }
    end

    context "when last query was attempted and rand is less than 0.1" do
      let!(:attempt) { create(:attempt) }

      before do
        allow(described_class).to receive(:rand).and_return(0.001)
      end

      it { is_expected.to be_truthy }
    end

    context "when last query was attempted and rand is greater than 0.1" do
      let!(:attempt) { create(:attempt) }

      before do
        allow(described_class).to receive(:rand).and_return(0.2)
      end

      it { is_expected.to be_falsey }
    end
  end
end
