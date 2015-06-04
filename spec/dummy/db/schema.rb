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

ActiveRecord::Schema.define(version: 20150604033650) do

  create_table "customers", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "stripe_customer_id"
  end

  add_index "customers", ["user_id"], name: "index_customers_on_user_id"

  create_table "magnetik_credit_cards", force: :cascade do |t|
    t.string   "stripe_card_id"
    t.string   "last_4_digits"
    t.string   "exp_month"
    t.string   "exp_year"
    t.string   "brand"
    t.boolean  "is_default"
    t.integer  "customer_id"
    t.string   "customer_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "magnetik_credit_cards", ["customer_id", "customer_id"], name: "index_magnetik_credit_cards_on_customer_id_and_customer_id"

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "stripe_customer_id"
  end

end
