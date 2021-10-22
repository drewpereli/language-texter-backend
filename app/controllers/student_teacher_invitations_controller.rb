# frozen_string_literal: true

class StudentTeacherInvitationsController < ApplicationController
  before_action :set_invitation, only: %i[update destroy]

  def index
    @invitations = policy_scope(StudentTeacherInvitation)

    render json: @invitations
  end

  def create
    @invitation = StudentTeacherInvitation.new(create_params.merge(creator: current_user))

    authorize(@invitation)

    if @invitation.save
      @invitation.send_invitation_message
      render json: @invitation, status: :created, location: @invitation
    else
      render json: @invitation.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize(@invitation)

    @invitation.respond_and_notify(update_params[:status])

    if @invitation.valid?
      render json: @invitation
    else
      render json: @invitation.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize(@invitation)
    @invitation.destroy
  end

  private

  def set_invitation
    @invitation = StudentTeacherInvitation.find(params[:id])
  end

  def create_params
    params.require(:student_teacher_invitation).permit(:recipient_name, :recipient_phone_number, :requested_role)
  end

  def update_params
    params.require(:student_teacher_invitation).permit(:status)
  end
end
