# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :ensure_authenticated

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers["Authorization"]
  end

  def decoded_token
    return unless auth_header

    token = auth_header.split[1]
    # header: { 'Authorization': 'Bearer <token>' }
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: "HS256")
    rescue JWT::DecodeError
      nil
    end
  end

  def current_user
    return unless decoded_token

    user_id = decoded_token[0]["user_id"]
    @user = User.find_by(id: user_id)
  end

  def logged_in?
    !!current_user
  end

  def ensure_authenticated
    render json: {message: "Please log in"}, status: :unauthorized unless logged_in?
  end
end
