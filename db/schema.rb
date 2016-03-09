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

ActiveRecord::Schema.define(version: 20160307012420) do

  create_table "barcode", id: false, force: :cascade do |t|
    t.string   "uuid",                           null: false
    t.string   "name"
    t.string   "stock_master_id"
    t.string   "parent_id"
    t.string   "child"
    t.string   "old_id"
    t.string   "lgort"
    t.string   "status"
    t.integer  "menge",           precision: 38
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "storage"
    t.integer  "seq",             precision: 38
  end

  add_index "barcode", ["name"], name: "index_barcode_on_name"
  add_index "barcode", ["seq"], name: "index_barcode_on_seq"
  add_index "barcode", ["storage"], name: "index_barcode_on_storage"
  add_index "barcode", ["uuid"], name: "index_barcode_on_uuid", unique: true

  create_table "printer", id: false, force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "code"
    t.string   "name"
    t.string   "ip"
    t.string   "port"
    t.string   "creator_id"
    t.string   "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "printer", ["code"], name: "index_printer_on_code"
  add_index "printer", ["uuid"], name: "index_printer_on_uuid", unique: true

  create_table "stock_master", id: false, force: :cascade do |t|
    t.string   "uuid",                      null: false
    t.string   "matnr"
    t.string   "maktx"
    t.string   "matkl"
    t.string   "charg"
    t.integer  "menge",      precision: 38
    t.integer  "box_cnt",    precision: 38
    t.integer  "pallet_cnt", precision: 38
    t.string   "werks"
    t.string   "meins"
    t.string   "mjahr"
    t.string   "mblnr"
    t.string   "zeile"
    t.string   "aufnr"
    t.string   "prdln"
    t.string   "ebeln"
    t.string   "ebelp"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "datecode"
    t.string   "budat"
  end

  add_index "stock_master", ["aufnr"], name: "index_stock_master_on_aufnr"
  add_index "stock_master", ["matnr"], name: "index_stock_master_on_matnr"
  add_index "stock_master", ["mjahr", "mblnr", "zeile"], name: "i_sto_mas_mja_mbl_zei"
  add_index "stock_master", ["uuid"], name: "index_stock_master_on_uuid", unique: true

  create_table "stock_tran", id: false, force: :cascade do |t|
    t.string   "uuid",                       null: false
    t.string   "master_id"
    t.string   "barcode_id"
    t.string   "lgort_old"
    t.string   "lgort"
    t.string   "status"
    t.integer  "menge",       precision: 38
    t.string   "vbeln"
    t.string   "posnr"
    t.string   "meins"
    t.string   "mjahr"
    t.string   "mblnr"
    t.string   "zeile"
    t.string   "aufnr"
    t.string   "prdln"
    t.string   "ebeln"
    t.string   "ebelp"
    t.string   "mtype"
    t.string   "created_by"
    t.string   "created_ip"
    t.string   "created_mac"
    t.string   "updated_by"
    t.string   "updated_ip"
    t.string   "updated_mac"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "stock_tran", ["barcode_id"], name: "index_stock_tran_on_barcode_id"
  add_index "stock_tran", ["master_id"], name: "index_stock_tran_on_master_id"
  add_index "stock_tran", ["uuid"], name: "index_stock_tran_on_uuid", unique: true

  create_table "storage", id: false, force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "code"
    t.string   "name"
    t.string   "werks"
    t.string   "creator_id"
    t.string   "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "storage", ["code"], name: "index_storage_on_code"
  add_index "storage", ["uuid"], name: "index_storage_on_uuid", unique: true

  create_table "user", id: false, force: :cascade do |t|
    t.string   "uuid",                                               null: false
    t.string   "email",                                 default: "", null: false
    t.string   "encrypted_password",                    default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          precision: 38, default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "role"
    t.integer  "supplier_id",            precision: 38
    t.string   "territory"
    t.string   "printer_id"
  end

  add_index "user", ["email"], name: "index_user_on_email", unique: true
  add_index "user", ["reset_password_token"], name: "i_user_reset_password_token", unique: true
  add_index "user", ["username"], name: "index_user_on_username", unique: true
  add_index "user", ["uuid"], name: "index_user_on_uuid", unique: true

  add_synonym "users", "istock.user", force: true

end
