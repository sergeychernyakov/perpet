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

ActiveRecord::Schema[8.1].define(version: 2026_09_16_062320) do
  create_table "ads", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "kind"
    t.string "period"
    t.string "price"
    t.integer "profile_id"
    t.date "published_on"
    t.string "search_text"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_ads_on_kind"
    t.index ["profile_id"], name: "index_ads_on_profile_id"
    t.index ["status"], name: "index_ads_on_status"
  end

  create_table "articles", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.integer "position"
    t.string "read_time"
    t.string "tag"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "faq_items", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "question"
    t.datetime "updated_at", null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "kind"
    t.string "name"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "pet_age"
    t.string "pet_name"
    t.datetime "updated_at", null: false
  end

  create_table "support_channels", force: :cascade do |t|
    t.string "availability"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "href"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "value"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name"
    t.string "reference"
    t.string "topic"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "ads", "profiles"
end
