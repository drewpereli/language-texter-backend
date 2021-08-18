# frozen_string_literal: true

shared_context "with authenticated_headers" do
  let(:authenticated_headers) do
    {
      "Accept" => "application/json",
      "Authorization" => "Bearer #{user.token}"
    }
  end
end
