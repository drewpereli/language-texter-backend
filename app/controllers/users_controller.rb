# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :ensure_authenticated

  def login
    @user = User.find_by(username: login_params[:username])

    if @user&.authenticate(login_params[:password])
      token = @user.token
      render json: {user: {id: @user.id, username: @user.username}, token: token}
    else
      render json: {errors: "Invalid username or password"}, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:username, :password)
  end
end
