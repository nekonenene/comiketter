# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "circle_spaces", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "イベント参加スペース" do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id"
    t.integer "day", limit: 1, comment: "参戦日", unsigned: true
    t.string "hall_name", limit: 32, comment: "東1, 西3などの館名"
    t.string "space_prefix", limit: 8, comment: "キ23aにおけるキ"
    t.integer "space_number", limit: 2, comment: "キ23aにおける23", unsigned: true
    t.string "space_side", limit: 8, comment: "キ23aにおけるa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_circle_spaces_on_event_id"
    t.index ["user_id"], name: "index_circle_spaces_on_user_id"
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "イベント" do |t|
    t.string "code", null: false, comment: "comike93 など、イベントを一意で示すID文字列"
    t.string "display_name", comment: "コミックマーケット93 などイベント名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_events_on_code", unique: true
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "for activerecord-session_store" do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string "handle", collation: "utf8mb4_general_ci", comment: "メンションに使われるID"
    t.string "username"
    t.string "provider", collation: "utf8mb4_general_ci"
    t.string "uid"
    t.string "access_token"
    t.string "encrypted_access_token_secret"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handle"], name: "index_users_on_handle"
    t.index ["provider", "uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "circle_spaces", "events", name: "fk_events_on_circle_spaces", on_update: :cascade, on_delete: :nullify
  add_foreign_key "circle_spaces", "users", name: "fk_users_on_circle_spaces", on_update: :cascade, on_delete: :cascade
end
