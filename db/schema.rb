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

ActiveRecord::Schema.define(version: 20161205003610) do

  create_table "activities", force: :cascade do |t|
    t.string   "title"
    t.string   "content"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "user_id"
    t.boolean  "is_completed",            default: false
    t.integer  "points",                  default: 0
    t.integer  "percent_complete",        default: 0
    t.float    "duration",                default: 0.0
    t.text     "code",                    default: "xyz"
    t.integer  "a_id",                    default: 1
    t.datetime "activity_time_completed"
    t.datetime "abort_time"
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.text     "content"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "comments", ["activity_id"], name: "index_comments_on_activity_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "points", force: :cascade do |t|
    t.integer  "activity_id"
    t.float    "timestamps"
    t.integer  "state"
    t.integer  "point_value"
    t.float    "time_left"
    t.string   "condition"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "points", ["activity_id"], name: "index_points_on_activity_id"

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "quitters", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id"
    t.string   "time_quit"
    t.string   "tetris_time"
    t.string   "activityAbortTime"
    t.string   "activity_id"
    t.string   "activity_start_time"
    t.string   "activity_finish_time"
  end

  create_table "todos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "encrypted_password",      default: "",                  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,                   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name"
    t.integer  "score",                   default: 0
    t.integer  "level",                   default: 1
    t.text     "experimental_condition",  default: "Initial condition"
    t.string   "experiment_state"
    t.boolean  "is_active",               default: true
    t.boolean  "is_admin",                default: false
    t.boolean  "finished_all_activities", default: false
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["user_name"], name: "index_users_on_user_name", unique: true

end
