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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130420153644) do

  create_table "agendas", :force => true do |t|
    t.string   "name"
    t.datetime "date"
    t.integer  "user_id"
  end

  create_table "bills", :force => true do |t|
    t.string   "name"
    t.datetime "date"
    t.integer  "user_id"
  end

  create_table "dreams", :force => true do |t|
    t.string   "dream_name"
    t.float    "cost"
    t.float    "value_per_week"
    t.float    "saved"
    t.float    "weekly_saved"
    t.datetime "date"
    t.datetime "next_week"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string  "phone_number"
    t.string  "name"
    t.integer "number_dreams"
    t.integer "uid"
  end

end
