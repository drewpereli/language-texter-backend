# frozen_string_literal: true

require "rails_helper"

RSpec.describe Challenge, type: :model do
  describe ".need_more_active?" do
    subject(:need_more_active) { described_class.need_more_active? }

    context "when the number of active challenges is greater than MAX_ACTIVE" do
      before do
        create_list(:challenge, Challenge::MAX_ACTIVE + 10, status: "active")
      end

      it { is_expected.to be_falsey }
    end

    context "when the number of active challenges is equal to MAX_ACTIVE" do
      before do
        create_list(:challenge, Challenge::MAX_ACTIVE, status: "active")
      end

      it { is_expected.to be_falsey }
    end

    context "when the number of active challenges is less than MAX_ACTIVE" do
      before do
        create_list(:challenge, Challenge::MAX_ACTIVE - 1, status: "active")
      end

      it { is_expected.to be_truthy }
    end
  end

  describe ".first_in_queue" do
    subject(:first_in_queue) { described_class.first_in_queue }

    let!(:first) { create(:challenge, status: "queued") }
    let!(:second) { create(:challenge, status: "queued") }

    it "returns the oldest item queued" do
      expect(first_in_queue.id).to eql(first.id)
    end
  end

  describe "#mark_as_complete" do
    subject(:mark_as_complete) { challenge.mark_as_complete }

    include_context "with twilio_client stub"

    let(:challenge) { create(:challenge) }

    it "updates the challenge status and texts christina" do
      expect_any_instance_of(User)
        .to receive(:text)
              .with("#{challenge.student.username}"\
                    " has completed the challenge \"#{challenge.learning_language_text}\"!")
              .and_return(nil)

      mark_as_complete

      challenge.reload

      expect(challenge).to be_complete
    end

    context "when more challenges need to be activated" do
      let!(:queued) { create(:challenge, status: "queued") }

      it "activates the last queued challenge" do
        mark_as_complete
        queued.reload
        expect(queued).to be_active
      end

      it "texts the creator" do
        mark_as_complete
        expect(twilio_client).to have_received(:text_number).with(challenge.creator.phone_number, String)
      end
    end

    context "when more challenges don't need to be activated" do
      let!(:queued) { create(:challenge, status: "queued") }

      before do
        create_list(:challenge, Challenge::MAX_ACTIVE + 10, status: "active")
      end

      it "does not activate the last queued challenge" do
        mark_as_complete
        queued.reload
        expect(queued).to be_queued
      end

      it "texts the creator" do
        mark_as_complete
        expect(twilio_client).to have_received(:text_number).with(challenge.creator.phone_number, String)
      end
    end
  end

  describe ".create_and_process" do
    subject(:create_and_process) { described_class.create_and_process(attrs) }

    include_context "with twilio_client stub"

    let(:student) { create(:user) }
    let(:creator) { create(:user) }

    let(:attrs) do
      {learning_language_text: "foo", native_language_text: "bar", student: student, creator: creator,
       required_score: 20}
    end

    context "when attrs are all valid" do
      it "creates a challenge" do
        expect { create_and_process }.to change(described_class, :count).by(1)
      end

      it "texts the student" do
        create_and_process
        expect(twilio_client).to have_received(:text_number).with(student.phone_number, /challenged added/)
      end
    end

    context "when all attrs are valid but student and creator are same" do
      let(:attrs) do
        {learning_language_text: "foo", native_language_text: "bar", student: student, creator: student,
         required_score: 20}
      end

      it "creates a challenge" do
        expect { create_and_process }.to change(described_class, :count).by(1)
      end

      it "does not send a text" do
        create_and_process
        expect(twilio_client).not_to have_received(:text_number)
      end
    end

    context "when native_language text and learning_language text has extra spaces" do
      let(:attrs) do
        {learning_language_text: "  foo    ", native_language_text: "  bar    ", student: student, creator: creator,
         required_score: 20}
      end

      it "strips them" do
        challenge = create_and_process

        expect(challenge.learning_language_text).to eql("foo")
        expect(challenge.native_language_text).to eql("bar")
      end
    end

    context "when attrs are invalid" do
      let(:attrs) do
        {learning_language_text: nil, native_language_text: "bar", student: student, creator: creator,
         required_score: 20}
      end

      it "doesn't create a challenge" do
        expect { create_and_process }.to change(described_class, :count).by(0)
      end

      it "doesn't text the student" do
        expect_any_instance_of(User).not_to receive(:text)
        create_and_process
      end
    end

    context "when there aren't enough active challenges" do
      it "activates the challenge" do
        challenge = create_and_process
        challenge.reload
        expect(challenge).to be_active
      end
    end

    context "when there are enough active challenges" do
      before do
        create_list(:challenge, Challenge::MAX_ACTIVE, status: "active")
      end

      it "queues the challenge" do
        challenge = create_and_process
        challenge.reload
        expect(challenge).to be_queued
      end
    end
  end

  describe "#process_attempt" do
    subject(:process_attempt) { challenge.process_attempt(attempt) }

    include_context "with twilio_client stub"

    let(:challenge) { create(:challenge) }

    context "when attempt is 'incorrect_active'" do
      let(:attempt) { create(:attempt, result_status: "incorrect_active", challenge: challenge) }

      it "resets the current streak to 0" do
        challenge.update(current_score: 10)
        process_attempt
        challenge.reload
        expect(challenge.current_score).to be 0
      end
    end

    context "when attempt is 'correct_active_insufficient'" do
      let(:attempt) { create(:attempt, result_status: "correct_active_insufficient", challenge: challenge) }

      it "increments the current streak" do
        challenge.update(current_score: 5)
        process_attempt
        challenge.reload
        expect(challenge.current_score).to be 6
      end
    end

    context "when attempt is 'correct_active_sufficient'" do
      let(:attempt) { create(:attempt, result_status: "correct_active_sufficient", challenge: challenge) }

      it "increments the current streak" do
        challenge.update(current_score: 5)
        process_attempt
        challenge.reload
        expect(challenge.current_score).to be 6
      end

      it "calls #mark_as_complete on the challenge" do
        expect(challenge).to receive(:mark_as_complete)
        process_attempt
      end
    end

    context "when attempt is 'incorrect_complete'" do
      let(:attempt) { create(:attempt, result_status: "incorrect_complete", challenge: challenge) }

      it "resets the current streak to 0" do
        challenge.update(current_score: 10)
        process_attempt
        challenge.reload
        expect(challenge.current_score).to be 0
      end

      it "reactivates the challenge" do
        challenge.complete!
        process_attempt
        challenge.reload
        expect(challenge).to be_active
      end
    end

    context "when attempt is 'correct_complete'" do
      let(:attempt) { create(:attempt, result_status: "correct_complete", challenge: challenge) }

      it "increments the current streak" do
        challenge.update(current_score: 5)
        process_attempt
        challenge.reload
        expect(challenge.current_score).to be 6
      end
    end
  end
end
