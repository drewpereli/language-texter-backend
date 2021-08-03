# frozen_string_literal: true

class TwilioClient
  def client
    @client ||= Twilio::REST::Client.new(Rails.application.credentials.twilio[:account_ssid],
                                         Rails.application.credentials.twilio[:auth_token])
  end

  def text_number(number, message)
    client.messages.create({
      from: from_number,
      to: number,
      body: message
    })
  end

  private

  def from_number
    Rails.application.credentials.twilio[:phone_number]
  end
end
