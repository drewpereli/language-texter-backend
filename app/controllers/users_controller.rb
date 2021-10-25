# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :ensure_authenticated, only: %i[create login confirm]
  skip_after_action :verify_authorized, only: %i[me change_password login confirm]

  def index
    @users = policy_scope(User)

    render json: @users
  end

  def create
    authorize(User)

    @user = User.create_and_send_confirmation(create_params)

    if @user.valid?
      render json: @user
    else
      render json: {errors: @user.errors}, status: :unauthorized
    end
  end

  def me
    render json: current_user
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

    if @user.nil? || !@user&.authenticate(login_params[:password])
      render json: {errors: "Invalid username or password"}, status: :unauthorized
    elsif !@user.confirmed
      render json: {errors: "You haven't confirmed your account yet"}, status: :unauthorized
    else
      token = @user.jwt_token
      render json: {token: token}
    end
  end

  def confirm
    @user = User.find_by(id: params[:id])

    return render json: {errors: ["Invalid user id or token"]}, status: :not_found if @user.nil?

    return render json: {errors: ["User already confirmed"]}, status: :not_found if @user.confirmed

    # Unconfirmed users should never have a nil token
    if @user.confirmation_token.nil?
      return render json: {errors: ["There was an error"]},
                    status: :internal_server_error
    end

    unless confirm_params[:confirmation_token] == @user.confirmation_token
      return render json: {errors: ["Invalid user id or token"]}, status: :not_found
    end

    @user.confirm!

    render json: @user
  end

  private

  def create_params
    params.require(:user).permit(:username, :phone_number, :password, :password_confirmation)
  end

  def login_params
    params.permit(:username, :password)
  end

  def confirm_params
    params.permit(:confirmation_token)
  end

  def change_password_params
    params.permit(:old_password, :new_password, :new_password_confirmation)
  end
end
