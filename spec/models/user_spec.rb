# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#valid?" do
    context "when all required fields are present" do
      let(:user) { create(:user) }

      it "is true" do
        expect(user).to be_valid
      end
    end

    context "when some required fields are missing" do
      shared_examples "field is required" do |params|
        let(:user) { create(:user) }

        before do
          user[params[:field]] = nil
        end

        it "is false when #{params[:field]} is nil" do
          expect(user).not_to be_valid
        end
      end

      required_fields = %i[
        username
        phone_number
        password_digest
      ]

      required_fields.each do |field|
        include_examples "field is required", {field: field}
      end
    end

    context "when password is empty on a new model" do
      let(:user) { build(:user) }

      before do
        user.password = nil
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when password is less than 12 characters long on a new model" do
      let(:user) { build(:user) }

      before do
        user.password = "this-is-bad"
        user.password_confirmation = "this-is-bad"
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when password_confirmation is empty on a new model" do
      let(:user) { build(:user) }

      before do
        user.password_confirmation = nil
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when password doesn't match password confirmation" do
      let(:user) { create(:user) }

      before do
        user.password = "foo"
        user.password_confirmation = "bar"
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when trying to create a user with a username that's been taken already" do
      let!(:old_user) { create(:user, username: "foo") }
      let(:user) { create(:user, username: "other") }

      before do
        user.username = "foo"
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when trying to create a user with a phone number that's been taken already" do
      let!(:old_user) { create(:user, phone_number: "222-333-4444") }
      let(:user) { create(:user, phone_number: "555-666-7777") }

      before do
        user.phone_number = "222-333-4444"
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when phone number is invalid" do
      let(:user) { create(:user) }

      before { user.phone_number = "abc" }

      it "is false" do
        expect(user).not_to be_valid
      end
    end

    context "when updating user attrs besides password" do
      let(:user) { create(:user) }

      before do
        user.update(username: "my new username")
      end

      it "is true" do
        expect(user).to be_valid
      end
    end

    context "when updating password to something invalid" do
      let(:user) { create(:user) }

      before do
        user.update(password: "a", password_confirmation: "a")
      end

      it "is false" do
        expect(user).not_to be_valid
      end
    end
  end

  describe ".save" do
    let(:user) { create(:user) }

    before do
      user.phone_number = "222-333-4444"
      user.save
      user.reload
    end

    it "normalizes the phone number before saving" do
      expect(user.phone_number).to eql("+12223334444")
    end
  end

  describe "#invitations_sent_within_last_week" do
    subject(:invitations_sent_within_last_week) { user.invitations_sent_within_last_week }

    let(:user) { create(:user) }

    before do
      create(:student_teacher_invitation, creator: user, created_at: 2.weeks.ago, id: 1)
      create(:student_teacher_invitation, creator: user, created_at: 1.day.ago, id: 2)
      create(:student_teacher_invitation, creator: user, created_at: 3.weeks.ago, id: 3)
      create(:student_teacher_invitation, creator: user, created_at: 5.weeks.ago, id: 4)
      create(:student_teacher_invitation, creator: user, created_at: 2.days.ago, id: 5)
      create(:student_teacher_invitation, recipient: user, created_at: 2.days.ago, id: 6)
      create(:student_teacher_invitation, recipient: user, created_at: 3.days.ago, id: 7)
    end

    it "includes the invitations created within the last week" do
      expect(invitations_sent_within_last_week.ids).to match_array([2, 5])
    end
  end

  describe "#students" do
    subject(:students) { user.students }

    let(:user) { create(:user, id: 1) }

    let!(:s1) { create(:user, id: 2) }
    let!(:s2) { create(:user, id: 3) }
    let!(:s3) { create(:user, id: 4) }
    let!(:t1) { create(:user, id: 5) }
    let!(:t2) { create(:user, id: 6) }
    let!(:t3) { create(:user, id: 7) }
    let!(:n1) { create(:user, id: 8) }
    let!(:n2) { create(:user, id: 9) }
    let!(:n3) { create(:user, id: 10) }

    before do
      create(:student_teacher, teacher: user, student: s1)
      create(:student_teacher, teacher: user, student: s2)
      create(:student_teacher, teacher: user, student: s3)
      create(:student_teacher, student: user, teacher: t1)
      create(:student_teacher, student: user, teacher: t2)
      create(:student_teacher, student: user, teacher: t3)
    end

    it "returns the students" do
      expect(students.ids).to match_array([s1.id, s2.id, s3.id])
    end
  end

  describe "#teachers" do
    subject(:teachers) { user.teachers }

    let(:user) { create(:user, id: 1) }

    let!(:s1) { create(:user, id: 2) }
    let!(:s2) { create(:user, id: 3) }
    let!(:s3) { create(:user, id: 4) }
    let!(:t1) { create(:user, id: 5) }
    let!(:t2) { create(:user, id: 6) }
    let!(:t3) { create(:user, id: 7) }
    let!(:n1) { create(:user, id: 8) }
    let!(:n2) { create(:user, id: 9) }
    let!(:n3) { create(:user, id: 10) }

    before do
      create(:student_teacher, teacher: user, student: s1)
      create(:student_teacher, teacher: user, student: s2)
      create(:student_teacher, teacher: user, student: s3)
      create(:student_teacher, student: user, teacher: t1)
      create(:student_teacher, student: user, teacher: t2)
      create(:student_teacher, student: user, teacher: t3)
    end

    it "returns the teachers" do
      expect(teachers.ids).to match_array([t1.id, t2.id, t3.id])
    end
  end

  describe "#inviters" do
    subject(:inviters) { user.inviters }

    let(:user) { create(:user, id: 1) }

    let!(:inviter_1) { create(:user, id: 2) }
    let!(:inviter_2) { create(:user, id: 3) }
    let!(:inviter_3) { create(:user, id: 4) }
    let!(:invitee_1) { create(:user, id: 5) }
    let!(:invitee_2) { create(:user, id: 6) }
    let!(:invitee_3) { create(:user, id: 7) }
    let!(:n1) { create(:user, id: 8) }
    let!(:n2) { create(:user, id: 9) }
    let!(:n3) { create(:user, id: 10) }

    before do
      create(:student_teacher_invitation, creator: inviter_1, recipient: user)
      create(:student_teacher_invitation, creator: inviter_2, recipient: user)
      create(:student_teacher_invitation, creator: inviter_3, recipient: user)

      create(:student_teacher_invitation, creator: user, recipient: invitee_1)
      create(:student_teacher_invitation, creator: user, recipient: invitee_2)
      create(:student_teacher_invitation, creator: user, recipient: invitee_3)
    end

    it "returns the inviters" do
      expect(inviters.ids).to match_array([
        inviter_1.id,
        inviter_2.id,
        inviter_3.id
      ])
    end
  end

  describe ".create_and_send_confirmation" do
    subject(:create_and_send_confirmation) { described_class.create_and_send_confirmation(attrs) }

    include_context "with twilio_client stub"

    let(:attrs) do
      password = "#{Faker::Internet.password(min_length: 12, mix_case: true)}1"

      {
        username: Faker::Internet.username,
        phone_number: "222-333-4444",
        password: password,
        password_confirmation: password,
        timezone: Faker::Address.time_zone
      }
    end

    it "creates a user" do
      expect { create_and_send_confirmation }.to change(described_class, :count).by(1)
    end

    it "creates a user settings model" do
      expect { create_and_send_confirmation }.to change(UserSettings, :count).by(1)
    end

    it "assigns the settings model to the user" do
      user = create_and_send_confirmation

      expect(user.user_settings).not_to be_nil
    end

    it "sends a confirmation link to the user" do
      create_and_send_confirmation
      expect(twilio_client).to have_received(:text_number).with("+12223334444",
                                                                /^Please click this link to confirm your account/)
    end
  end

  describe "#appropriate_time_for_text?" do
    subject(:appropriate_time_for_text?) { user.appropriate_time_for_text? }

    let(:user) { create(:user) }

    let(:timezone) { Faker::Address.time_zone }

    let(:time_now) { Time.find_zone(timezone).local(2000, 1, 1, hour_now, minute_now, 0) }
    let(:hour_now) { 12 }
    let(:minute_now) { 0 }

    before do
      allow(Time).to receive(:now).and_return(time_now)

      user.user_settings.timezone = timezone
    end

    context "when it is after 11 pm" do
      let(:hour_now) { 23 }
      let(:minute_now) { 30 }

      it { is_expected.to be_falsey }
    end

    context "when it is before 8 am" do
      let(:hour_now) { 7 }

      it { is_expected.to be_falsey }
    end

    context "when it is between 8 and 11" do
      it { is_expected.to be_truthy }
    end
  end

  describe "#questions_assigned" do
    subject(:questions_assigned) { user.questions_assigned }

    let(:user) { create(:user) }

    let!(:c1) { create(:challenge, student: user) }
    let!(:c2) { create(:challenge, student: user) }
    let!(:c3) { create(:challenge, student: user) }

    let!(:c4) { create(:challenge, creator: user) }

    let!(:c1_q1) { create(:question, challenge: c1, id: 1) }
    let!(:c2_q1) { create(:question, challenge: c2, id: 2) }
    let!(:c2_q2) { create(:question, challenge: c2, id: 3) }
    let!(:c3_q1) { create(:question, challenge: c3, id: 4) }

    let(:c4_q1) { create(:question, challenge: c4) }

    before do
      create_list(:question, 10)
    end

    it "returns the user's assigned questions" do
      expect(questions_assigned.ids).to match_array([1, 2, 3, 4])
    end
  end

  describe "#last_question" do
    subject(:last_question) { user.last_question }

    let(:user) { create(:user) }

    let!(:c1) { create(:challenge, student: user) }
    let!(:c2) { create(:challenge, student: user) }
    let!(:c3) { create(:challenge, student: user) }

    let!(:c4) { create(:challenge, creator: user) }

    let!(:c1_q1) { create(:question, challenge: c1, id: 1) }
    let!(:c2_q1) { create(:question, challenge: c2, id: 2) }
    let!(:c2_q2) { create(:question, challenge: c2, id: 3) }
    let!(:c3_q1) { create(:question, challenge: c3, id: 4) }

    let(:c4_q1) { create(:question, challenge: c4) }

    before do
      create_list(:question, 10)
    end

    it "returns the last question sent" do
      expect(last_question.id).to be(4)
    end
  end

  describe "#last_question_waiting_on_attempt?" do
    subject(:last_question_waiting_on_attempt?) { user.last_question_waiting_on_attempt? }

    let(:user) { create(:user) }

    context "when there are no challenges" do
      it { is_expected.to be_falsey }
    end

    context "when there are challenges but no questions" do
      before { create(:challenge, student: user) }

      it { is_expected.to be_falsey }
    end

    context "when there are challenges and questions, but all the questions have responses" do
      before do
        challenge = create(:challenge, student: user)

        question = create(:question, challenge: challenge)

        create(:attempt, :correct, question: question)
      end

      it { is_expected.to be_falsey }
    end

    context "when there are challenges and questions, but the last questions does not have a response" do
      before do
        challenge = create(:challenge, student: user)

        question = create(:question, challenge: challenge)

        create(:attempt, :correct, question: question)

        create(:question, challenge: challenge)
      end

      it { is_expected.to be_truthy }
    end
  end

  describe "#next_challenge" do
    subject(:next_challenge) { user.next_challenge }

    let(:user) { create(:user) }

    before do
      create_list(:challenge, 10)
      create_list(:challenge, 10, student: user, status: "queued")
    end

    context "when there are no active or complete challenges assigned to the user" do
      it { is_expected.to be_nil }
    end

    context "when rand is greater than SEND_OLD_CHALLENGE_PROBABILITY" do
      before do
        allow(user).to receive(:rand).and_return(1)
      end

      context "when there are challenges and none have been attempted" do
        before do
          create_list(:challenge, 5, student: user, status: "active")
        end

        it "returns a random user challenge" do
          expect(next_challenge.student.id).to be(user.id)
        end
      end

      context "when there are challenges and at least one has been attempted" do
        let!(:last_challenge_answered) { create(:challenge, student: user) }

        before do
          question = create(:question, challenge: last_challenge_answered)
          create(:attempt, question: question)

          create_list(:challenge, 5, student: user, status: "active")
        end

        it "returns a random user challenge that's not the last one sent" do
          challenge = next_challenge
          expect(challenge.student.id).to be(user.id)
          expect(challenge.id).not_to be(last_challenge_answered.id)
        end
      end

      context "when there is only one challenge and it has been attempted" do
        let!(:last_challenge_answered) { create(:challenge, student: user, status: "active") }

        before do
          question = create(:question, challenge: last_challenge_answered)
          create(:attempt, question: question)
        end

        it "returns a the challenge" do
          expect(next_challenge.id).to be(last_challenge_answered.id)
        end
      end

      context "when there is only one challenge and it's complete'" do
        let!(:last_challenge_answered) { create(:challenge, student: user, status: "complete") }

        it "returns a the challenge" do
          expect(next_challenge.id).to be(last_challenge_answered.id)
        end
      end
    end

    context "when rand is less than SEND_OLD_CHALLENGE_PROBABILITY" do
      before do
        allow(user).to receive(:rand).and_return(0)
      end

      context "when there are complete challenges" do
        before { create_list(:challenge, 10, student: user, status: "complete") }

        it "returns a random complete challenge" do
          expect(next_challenge).to be_complete
        end
      end

      context "when there is only one challenge and it's active'" do
        let!(:challenge) { create(:challenge, student: user, status: "active") }

        it "returns a the challenge" do
          expect(next_challenge.id).to be(challenge.id)
        end
      end
    end
  end

  describe "#send_question_if_time" do
    subject(:send_question_if_time) { user.send_question_if_time }

    include_context "with twilio_client stub"

    let(:user) { create(:user) }

    before { allow(user).to receive(:appropriate_time_for_text?).and_return(true) }

    context "when the user has no assigned challenges" do
      it "does not text the user" do
        send_question_if_time
        expect(twilio_client).not_to have_received(:text_number)
      end
    end

    context "when the last question has been answered and rand is less than TIME_FOR_NEW_QUESTION_PROBABILITY" do
      before do
        allow(user).to receive(:rand).and_return(0)

        create_list(:challenge, 10, student: user, status: "active")

        question = create(:question, challenge: user.challenges_assigned.active.sample)
        create(:attempt, question: question)
      end

      it "creates a new question" do
        expect { send_question_if_time }.to change(Question, :count).by(1)
      end

      it "texts the user the new question" do
        send_question_if_time
        expect(twilio_client).to have_received(:text_number).with(user.phone_number, Question.last.message)
      end
    end

    context "when the last question has been answered and rand is greater than TIME_FOR_NEW_QUESTION_PROBABILITY" do
      before do
        allow(user).to receive(:rand).and_return(1)
      end

      it "does not create a new question" do
        expect { send_question_if_time }.to change(Question, :count).by(0)
      end

      it "does not text the user" do
        send_question_if_time
        expect(twilio_client).not_to have_received(:text_number)
      end
    end

    context "when the last question hasn't been answered and a reminder hasn't been sent in a while" do
      let!(:challenge) { create(:challenge, student: user) }
      let!(:question) { create(:question, challenge: challenge, created_at: 1.year.ago, last_sent_at: 1.year.ago) }

      before do
        allow(user).to receive(:rand).and_return(0)
      end

      it "does not create a new question" do
        expect { send_question_if_time }.to change(Question, :count).by(0)
      end

      it "texts the user a reminder" do
        send_question_if_time
        expect(twilio_client).to have_received(:text_number).with(user.phone_number, question.reminder_message)
      end
    end

    context "when the last question hasn't been answered and but it was sent recently" do
      let!(:challenge) { create(:challenge, student: user) }
      let!(:question) { create(:question, challenge: challenge, created_at: 1.year.ago, last_sent_at: Time.now) }

      before do
        allow(user).to receive(:rand).and_return(0)
      end

      it "does not create a new question" do
        expect { send_question_if_time }.to change(Question, :count).by(0)
      end

      it "does not text the user" do
        send_question_if_time
        expect(twilio_client).not_to have_received(:text_number)
      end
    end

    context "when appropriate_time_for_text? is false" do
      before { allow(user).to receive(:appropriate_time_for_text?).and_return(false) }

      it "does not create a new question" do
        expect { send_question_if_time }.to change(Question, :count).by(0)
      end

      it "does not text the user" do
        send_question_if_time
        expect(twilio_client).not_to have_received(:text_number)
      end
    end
  end
end
