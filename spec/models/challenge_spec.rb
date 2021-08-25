# frozen_string_literal: true

# rubocop:disable RSpec/AnyInstance
# rubocop:disable RSpec/StubbedMock

require "rails_helper"

RSpec.describe Challenge, type: :model do
  describe "#current_streak" do
    subject(:current_streak) { challenge.current_streak }

    let(:u1) { create(:user, username: "u1", phone_number: "abc") }
    let(:u2) { create(:user, username: "u2", phone_number: "def") }
    let(:challenge) do
      create(:challenge, spanish_text: "amigo", english_text: "friend", user: u1, required_streak_for_completion: 3)
    end

    context "when the user hasn't responded yet" do
      it { is_expected.to be(0) }
    end

    context "when the user has respondent with some correct and some incorrect and the last one was incorrect" do
      before do
        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "asdfasdfasdf",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))
      end

      it { is_expected.to be(0) }
    end

    context "when the user has respondent with some correct and some incorrect and the last one was correct" do
      before do
        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "asdfasdfasdf",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))

        create(:attempt,
               text: "amigo",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "english"))

        create(:attempt,
               text: "friend",
               query: create(:query,
                             challenge: challenge,
                             user: u2,
                             language: "spanish"))
      end

      it "is the count of all the correct answers since the last incorrect answer" do
        expect(current_streak).to be(3)
      end
    end
  end

  describe "#mark_as_complete" do
    subject(:mark_as_complete) { challenge.mark_as_complete }

    let(:challenge) { create(:challenge) }

    before do
      create(:user, username: "christina", phone_number: "+18888888888")
    end

    it "updates the challenge status and texts christina" do
      expect_any_instance_of(User).to receive(:text)
        .with("Drew has completed the challenge \"#{challenge.spanish_text}\"!")
        .and_return(nil)

      mark_as_complete

      challenge.reload

      expect(challenge).to be_complete
    end
  end

  describe ".complete_and_process" do
    subject(:complete_and_process) { described_class.complete_and_process(challenge) }

    let(:challenge) { create(:challenge) }

    shared_examples "it marks the challenge as complete" do
      it "marks the challenge as complete" do
        complete_and_process

        challenge.reload

        expect(challenge).to be_complete
      end
    end

    context "when we need more active challenges but there are none in the queue" do
      include_examples "it marks the challenge as complete"
    end

    context "when we need more active challenges and there are some in the queue" do
      before do
        create_list(:challenge, 5, status: :queued)
      end

      include_examples "it marks the challenge as complete"

      it "makes first_in_que active" do
        first_in_queue_before = described_class.first_in_queue

        complete_and_process

        first_in_queue_before.reload

        expect(first_in_queue_before).to be_active
      end
    end

    context "when we don't need more active" do
      before do
        create_list(:challenge, Challenge::MAX_ACTIVE + 1, status: :active)
        create_list(:challenge, 5, status: :queued)
      end

      include_examples "it marks the challenge as complete"

      it "does not make first_in_que active" do
        first_in_queue_before = described_class.first_in_queue

        complete_and_process

        first_in_queue_before.reload

        expect(first_in_queue_before).not_to be_active
      end
    end
  end

  describe ".create_and_process" do
    subject(:create_and_process) { described_class.create_and_process(attrs) }

    let(:user) { create(:user, username: "drew") }

    let(:attrs) do
      {spanish_text: "foo", english_text: "bar", user: user}
    end

    before do
      allow_any_instance_of(User).to receive(:text).and_return(nil)
    end

    context "when attrs are all valid" do
      it "creates a challenge" do
        expect { create_and_process }.to change(described_class, :count).by(1)
      end

      it "texts drew" do
        expect_any_instance_of(User).to receive(:text)
        create_and_process
      end
    end

    context "when english text and spanish text has extra spaces" do
      let(:attrs) do
        {spanish_text: "  foo    ", english_text: "  bar    ", user: user}
      end

      it "strips them" do
        challenge = create_and_process

        expect(challenge.spanish_text).to eql("foo")
        expect(challenge.english_text).to eql("bar")
      end
    end

    context "when active challenges aren't maxed out" do
      it "sets the challenge to active" do
        expect(create_and_process).to be_active
      end
    end

    context "when active challenges are maxed out" do
      before do
        create_list(:challenge, described_class::MAX_ACTIVE, status: :active)
      end

      it "sets the challenge to queued" do
        expect(create_and_process).to be_queued
      end
    end

    context "when attrs are invalid" do
      let(:attrs) do
        {spanish_text: nil, english_text: "bar", user: user}
      end

      it "doesn't create a challenge" do
        expect { create_and_process }.to change(described_class, :count).by(0)
      end

      it "doesn't text drew" do
        expect_any_instance_of(User).not_to receive(:text)
        create_and_process
      end
    end
  end
end

# rubocop:enable RSpec/AnyInstance
# rubocop:enable RSpec/StubbedMock
