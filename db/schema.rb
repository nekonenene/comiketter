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

  create_table "circle_spaces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "イベント参加スペース", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id"
    t.integer "day", limit: 1, comment: "参戦日", unsigned: true
    t.string "hall_name", limit: 32, comment: "東1, 西3などの館名"
    t.string "space_prefix", limit: 8, comment: "キ09aにおけるキ"
    t.string "space_number", limit: 8, comment: "キ09aにおける09"
    t.string "space_side", limit: 8, comment: "キ09aにおけるa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_circle_spaces_on_event_id"
    t.index ["user_id"], name: "index_circle_spaces_on_user_id"
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "イベント", force: :cascade do |t|
    t.string "code", null: false, collation: "utf8mb4_general_ci", comment: "comike93 など、イベントを一意で示すID文字列"
    t.string "display_name", comment: "コミックマーケット93 などイベント名"
    t.date "start_date", comment: "開催開始日"
    t.integer "days", default: 1, comment: "開催期間", unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_events_on_code", unique: true
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "for activerecord-session_store", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "user_followers", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", comment: "フォロー・フォロワー関係テーブル", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "follower_user_id", null: false
    t.index ["follower_user_id"], name: "index_user_followers_on_follower_user_id"
    t.index ["user_id", "follower_user_id"], name: "index_user_followers_on_user_id_and_follower_user_id", unique: true
    t.index ["user_id"], name: "index_user_followers_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "provider", collation: "utf8mb4_general_ci"
    t.string "uid"
    t.string "handle", collation: "utf8mb4_general_ci", comment: "メンションに使われるID"
    t.string "username"
    t.string "icon_url"
    t.string "website_url"
    t.integer "followers_count"
    t.integer "friends_count"
    t.string "access_token"
    t.string "encrypted_access_token_secret"
    t.string "salt"
    t.datetime "last_signin_at"
    t.datetime "last_followers_updated_at"
    t.datetime "last_friends_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handle"], name: "index_users_on_handle"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "circle_spaces", "events", name: "fk_events_on_circle_spaces", on_update: :cascade, on_delete: :nullify
  add_foreign_key "circle_spaces", "users", name: "fk_users_on_circle_spaces", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_followers", "users", column: "follower_user_id", name: "fk_follower_users_on_user_followers", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_followers", "users", name: "fk_users_on_user_followers", on_update: :cascade, on_delete: :cascade
end
