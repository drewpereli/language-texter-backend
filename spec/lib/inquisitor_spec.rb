# frozen_string_literal: true

require "rails_helper"

RSpec.describe Inquisitor do
  describe ".appropriate_time_for_text?" do
    subject { described_class.appropriate_time_for_text? }

    let(:time_now) { Time.find_zone("US/Pacific").local(2000, 1, 1, hour_now, minute_now, 0) }
    let(:hour_now) { 12 }
    let(:minute_now) { 0 }

    before do
      allow(Time).to receive(:now).and_return(time_now)
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
  end
end
