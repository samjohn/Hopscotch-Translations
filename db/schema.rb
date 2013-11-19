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

ActiveRecord::Schema.define(version: 20131119194423) do

  create_table "english_words", force: true do |t|
    t.text     "translatable_string"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "non_app_string"
  end

  add_index "english_words", ["translatable_string"], name: "index_english_words_on_translatable_string", unique: true

  create_table "foreign_word_job_relations", force: true do |t|
  end

  create_table "foreign_words", force: true do |t|
    t.text     "translatable_string"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "foreign_words", ["translatable_string", "language"], name: "index_foreign_words_on_translatable_string_and_language", unique: true

  create_table "gengo_jobs", force: true do |t|
    t.string   "job_id"
    t.boolean  "completed",       default: false
    t.string   "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "foreign_word_id"
  end

  add_index "gengo_jobs", ["job_id"], name: "index_gengo_jobs_on_job_id", unique: true

  create_table "gengo_orders", force: true do |t|
    t.string   "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete"
    t.integer  "available_job_count"
  end

  add_index "gengo_orders", ["order_id"], name: "index_gengo_orders_on_order_id", unique: true

  create_table "submissions", force: true do |t|
    t.text     "translated_string"
    t.string   "contributor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "foreign_word_id"
  end

end
