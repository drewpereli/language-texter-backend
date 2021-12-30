# frozen_string_literal: true

class StudentTeacherInvitationsController < ApplicationController
  before_action :set_invitation, only: %i[update destroy]

  def index
    @invitations = policy_scope(StudentTeacherInvitation)

    render json: StudentTeacherInvitationBlueprint.render(@invitations, root: :student_teacher_invitations,
                                                                        current_user_id: current_user.id)
  end

  def create
    @invitation = StudentTeacherInvitation.new(create_params.merge(creator: current_user))

    authorize(@invitation)

    if @invitation.save
      @invitation.send_invitation_message

      response_body = StudentTeacherInvitationBlueprint.render(
        @invitation,
        root: :student_teacher_invitation,
        current_user_id: current_user.id
      )

      render json: response_body, status: :created, location: @invitation
    else
      render_model_errors(@invitation)
    end
  end

  def update
    authorize(@invitation)

    @invitation.respond_and_notify(update_params[:status])

    if @invitation.valid?
      render json: StudentTeacherInvitationBlueprint.render(@invitation, root: :student_teacher_invitation,
                                                                         current_user_id: current_user.id)
    else
      render_model_errors(@invitation)
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
