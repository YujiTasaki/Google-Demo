# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170719021310) do

  create_table "calendar_guests", force: :cascade do |t|
    t.string   "event_id"
    t.string   "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendar_to_locks", force: :cascade do |t|
    t.string   "calendar_id"
    t.string   "lock_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "connect_accounts", force: :cascade do |t|
    t.string   "key"
    t.string   "client_id"
    t.string   "client_secret"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "connect_locks", force: :cascade do |t|
    t.string   "uuid"
    t.string   "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "connect_tokens", force: :cascade do |t|
    t.string   "key"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "expire"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "status"
  end

  create_table "google_accounts", force: :cascade do |t|
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "calendar_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "account_id"
    t.string   "redirect_uri"
    t.string   "code"
  end

  create_table "google_api_execs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "google_calendars", force: :cascade do |t|
    t.string   "calendar_id"
    t.string   "account_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "google_channels", force: :cascade do |t|
    t.string   "channel_id"
    t.string   "calendar_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "expires_in"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "status"
    t.string   "resource_id"
  end

  create_table "google_tokens", force: :cascade do |t|
    t.string   "account_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "expire"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "status"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

end
