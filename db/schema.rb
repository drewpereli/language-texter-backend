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

ActiveRecord::Schema.define(version: 2021_08_06_172124) do

  create_table "attempts", force: :cascade do |t|
    t.string "text", null: false
    t.integer "query_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["query_id"], name: "index_attempts_on_query_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.string "spanish_text", null: false
    t.string "english_text", null: false
    t.integer "required_streak_for_completion", default: 20, null: false
    t.boolean "is_complete", default: false, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_challenges_on_user_id"
  end

  create_table "queries", force: :cascade do |t|
    t.integer "language", null: false
    t.integer "user_id", null: false
    t.integer "challenge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_sent_at"
    t.index ["challenge_id"], name: "index_queries_on_challenge_id"
    t.index ["user_id"], name: "index_queries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "phone_number", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
