# frozen_string_literal: true

shared_context "with twilio_client stub" do
  let(:twilio_client) { instance_double("TwilioClient") }

  before do
    allow(TwilioClient).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive(:text_number)
  end
end
