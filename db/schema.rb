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

ActiveRecord::Schema.define(version: 20160720030024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.integer  "friend_id",                 null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "active",     default: true, null: false
  end

  create_table "replies", force: :cascade do |t|
    t.integer  "reslyp_id",                  null: false
    t.integer  "sender_id",                  null: false
    t.string   "text",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "seen",       default: false, null: false
  end

  create_table "reslyps", force: :cascade do |t|
    t.integer  "slyp_id",                null: false
    t.integer  "recipient_user_slyp_id", null: false
    t.string   "comment"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "sender_id",              null: false
    t.integer  "recipient_id",           null: false
    t.integer  "sender_user_slyp_id",    null: false
  end

  create_table "slyps", force: :cascade do |t|
    t.string   "title"
    t.string   "author"
    t.date     "date"
    t.string   "display_url"
    t.string   "favicon"
    t.string   "site_name"
    t.string   "slyp_type"
    t.text     "text"
    t.integer  "duration"
    t.integer  "word_count"
    t.text     "html"
    t.string   "url",         null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  create_table "user_slyps", force: :cascade do |t|
    t.integer  "slyp_id",                         null: false
    t.integer  "user_id",                         null: false
    t.boolean  "favourite",       default: false, null: false
    t.boolean  "archived",        default: false, null: false
    t.boolean  "deleted",         default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "unseen_activity", default: false, null: false
    t.boolean  "unseen",          default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                   default: "",                    null: false
    t.string   "last_name",                    default: "",                    null: false
    t.string   "email",                        default: "",                    null: false
    t.string   "encrypted_password",           default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",              default: 0,                     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",            default: 0
    t.datetime "last_seen_at"
    t.string   "authentication_token"
    t.string   "image"
    t.boolean  "notify_reslyp",                default: true,                  null: false
    t.boolean  "notify_activity",              default: true,                  null: false
    t.boolean  "cc_on_reslyp_email_contact",   default: true,                  null: false
    t.boolean  "weekly_summary",               default: true,                  null: false
    t.boolean  "searchable",                   default: true,                  null: false
    t.integer  "status",                       default: 0,                     null: false
    t.string   "send_reslyp_email_from",       default: "support@slyp.io",     null: false
    t.string   "referral_token"
    t.datetime "activated_at",                 default: '2016-07-14 13:47:58'
    t.boolean  "send_new_friend_notification", default: true
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
