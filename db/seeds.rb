# frozen_string_literal: true

if Rails.env == "production"

  drew = User.find_by(username: "drew") ||
         User.create(
           {username: "drew", phone_number: "+1234567890", password: "password", password_confirmation: "password"}
         )

  if User.find_by(username: "christina").nil?
    User.create(
      {username: "christina", phone_number: "+2234567890", password: "password", password_confirmation: "password"}
    )
  end

  if Challenge.count.zero?
    challenge = Challenge.create(
      {spanish_text: "hola", english_text: "hello", user: drew}
    )

    question = Question.create(challenge: challenge, language: "spanish")

    question.send_message
  end
end
