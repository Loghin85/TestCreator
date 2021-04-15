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

ActiveRecord::Schema.define(version: 2021_03_09_140547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "questions", force: :cascade do |t|
		t.integer "assessment_id"
    t.string "Title"
    t.string "Text"
    t.string "Feedback"
    t.string "Type"
		t.integer "Points"
		t.string "Options"
		t.string "Answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end
	
	create_table "assessments", force: :cascade do |t|
    t.integer "user_id"
    t.string "Name"
    t.string "Description"
    t.integer "Duration"
    t.datetime "BeginAt"
		t.datetime "EndAt"
		t.timestamps
    t.index ["user_id"], name: "index_assessments_on_user_id"
  end
	
  create_table "submissions", force: :cascade do |t|
    t.integer "assessment_id"
    t.string "userId"
    t.string "userEmail"
    t.string "Scores"
    t.string "Answers"
    t.integer "Score"
    t.integer "Duration"
    t.datetime "SubmittedAt"
		t.timestamps
		t.index ["userId"], name: "index_submissions_on_userId", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "Fname"
    t.string "Lname"
    t.string "Email"
    t.string "Privilege", default: "User"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.index ["Email"], name: "index_users_on_email", unique: true
  end
end
