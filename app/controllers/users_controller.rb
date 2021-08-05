# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :ensure_authenticated, only: %i[login]

  def index
    @users = User.all

    render json: @users
  end

  def change_password
    @user = current_user

    if @user.authenticate(change_password_params[:old_password])
      @user.update(password: change_password_params[:new_password],
                   password_confirmation: change_password_params[:new_password_confirmation])

      if @user.valid?
        head :no_content
      else
        render json: {errors: "New password doesn't match new password confirmation"}, status: :unauthorized
      end
    else
      render json: {errors: "Old password incorrect"}, status: :unauthorized
    end
  end

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

  def change_password_params
    params.permit(:old_password, :new_password, :new_password_confirmation)
  end
end
