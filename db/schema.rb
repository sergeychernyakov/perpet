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

ActiveRecord::Schema[8.1].define(version: 2026_09_16_165154) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
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

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "vk_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["vk_id"], name: "index_users_on_vk_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ads", "profiles"
  add_foreign_key "profiles", "users"
end
