# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_04_071137) do

  create_table "attempts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "question_id", null: false
    t.integer "result_status"
    t.string "text", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_attempts_on_question_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "creator_id", null: false
    t.integer "current_score", default: 0, null: false
    t.integer "language_id"
    t.string "learning_language_text", null: false
    t.string "learning_language_text_note"
    t.string "native_language_text", null: false
    t.string "native_language_text_note"
    t.integer "required_score", null: false
    t.integer "status", default: 0, null: false
    t.integer "student_id", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_challenges_on_creator_id"
    t.index ["language_id"], name: "index_challenges_on_language_id"
    t.index ["student_id"], name: "index_challenges_on_student_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", precision: 6, null: false
    t.string "name", null: false
    t.string "native_name", null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.boolean "for_already_completed_challenge", default: false, null: false
    t.integer "language", default: 0, null: false
    t.datetime "last_sent_at"
    t.datetime "updated_at", precision: 6, null: false
    t.index ["challenge_id"], name: "index_questions_on_challenge_id"
  end

  create_table "student_teacher_invitations", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "creator_id", null: false
    t.string "recipient_name", null: false
    t.string "recipient_phone_number", null: false
    t.integer "requested_role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "student_teachers", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "student_id", null: false
    t.integer "teacher_id", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["student_id", "teacher_id"], name: "index_student_teachers_on_student_id_and_teacher_id", unique: true
  end

  create_table "user_settings", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "default_challenge_language_id"
    t.time "earliest_text_time", default: "2000-01-01 09:00:00", null: false
    t.time "latest_text_time", default: "2000-01-01 22:00:00", null: false
    t.integer "reminder_frequency"
    t.string "timezone", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "confirmation_token"
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.string "language_learning", default: "es", null: false
    t.string "password_digest", null: false
    t.string "phone_number", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
