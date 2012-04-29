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

ActiveRecord::Schema.define(:version => 20120428235027) do

  create_table "eden_heros", :force => true do |t|
    t.string   "name"
    t.integer  "character_id"
    t.integer  "earned_bounty_amt"
    t.string   "killuri"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "wanted_toons", :force => true do |t|
    t.integer  "character_id"
    t.string   "name"
    t.integer  "bounty"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "wt_ships", :force => true do |t|
    t.string   "lossurl"
    t.string   "ship_type"
    t.integer  "isk_dropped"
    t.integer  "isk_destroyed"
    t.integer  "payout_amt"
    t.integer  "wanted_toon_id"
    t.string   "solar_system"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "eve_time_date"
    t.string   "lost_to"
  end

end
