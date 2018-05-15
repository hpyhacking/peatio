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

ActiveRecord::Schema.define(version: 20180501141718) do

  create_table "account_versions", force: :cascade do |t|
    t.integer  "member_id",       limit: 4
    t.integer  "account_id",      limit: 4
    t.integer  "reason",          limit: 4
    t.decimal  "balance",                     precision: 32, scale: 16
    t.decimal  "locked",                      precision: 32, scale: 16
    t.decimal  "fee",                         precision: 32, scale: 16
    t.decimal  "amount",                      precision: 32, scale: 16
    t.integer  "modifiable_id",   limit: 4
    t.string   "modifiable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id",     limit: 4
    t.integer  "fun",             limit: 4
  end

  add_index "account_versions", ["account_id", "reason"], name: "index_account_versions_on_account_id_and_reason", using: :btree
  add_index "account_versions", ["account_id"], name: "index_account_versions_on_account_id", using: :btree
  add_index "account_versions", ["currency_id"], name: "index_account_versions_on_currency_id", using: :btree
  add_index "account_versions", ["member_id", "reason"], name: "index_account_versions_on_member_id_and_reason", using: :btree
  add_index "account_versions", ["modifiable_id", "modifiable_type"], name: "index_account_versions_on_modifiable_id_and_modifiable_type", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "member_id",   limit: 4
    t.integer  "currency_id", limit: 4
    t.decimal  "balance",               precision: 32, scale: 16
    t.decimal  "locked",                precision: 32, scale: 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["currency_id"], name: "index_accounts_on_currency_id", using: :btree
  add_index "accounts", ["member_id", "currency_id"], name: "index_accounts_on_member_id_and_currency_id", using: :btree
  add_index "accounts", ["member_id"], name: "index_accounts_on_member_id", using: :btree

  create_table "audit_logs", force: :cascade do |t|
    t.string   "type",           limit: 255
    t.integer  "operator_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "auditable_id",   limit: 4
    t.string   "auditable_type", limit: 255
    t.string   "source_state",   limit: 255
    t.string   "target_state",   limit: 255
  end

  add_index "audit_logs", ["auditable_id", "auditable_type"], name: "index_audit_logs_on_auditable_id_and_auditable_type", using: :btree
  add_index "audit_logs", ["operator_id"], name: "index_audit_logs_on_operator_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.text     "token",      limit: 65535
    t.integer  "member_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["member_id"], name: "index_authentications_on_member_id", using: :btree
  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "code",                 limit: 30,                                              null: false
    t.string   "symbol",               limit: 1,                                               null: false
    t.string   "type",                 limit: 30,                             default: "coin", null: false
    t.decimal  "deposit_fee",                       precision: 32, scale: 16, default: 0.0,    null: false
    t.decimal  "quick_withdraw_limit",              precision: 32, scale: 16, default: 0.0,    null: false
    t.decimal  "withdraw_fee",                      precision: 32, scale: 16, default: 0.0,    null: false
    t.string   "options",              limit: 1000,                           default: "{}",   null: false
    t.boolean  "visible",                                                     default: true,   null: false
    t.integer  "base_factor",          limit: 8,                              default: 1,      null: false
    t.integer  "precision",            limit: 1,                              default: 8,      null: false
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
  end

  add_index "currencies", ["code"], name: "index_currencies_on_code", unique: true, using: :btree
  add_index "currencies", ["visible"], name: "index_currencies_on_visible", using: :btree

  create_table "deposits", force: :cascade do |t|
    t.integer  "member_id",     limit: 4,                                         null: false
    t.integer  "currency_id",   limit: 4,                                         null: false
    t.decimal  "amount",                    precision: 32, scale: 16,             null: false
    t.decimal  "fee",                       precision: 32, scale: 16,             null: false
    t.string   "address",       limit: 64
    t.string   "txid",          limit: 128
    t.integer  "txout",         limit: 4
    t.string   "aasm_state",    limit: 255,                                       null: false
    t.integer  "confirmations", limit: 4,                             default: 0, null: false
    t.string   "type",          limit: 30,                                        null: false
    t.string   "tid",           limit: 64,                                        null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.datetime "completed_at"
  end

  add_index "deposits", ["currency_id", "txid", "txout"], name: "index_deposits_on_currency_id_and_txid_and_txout", unique: true, using: :btree
  add_index "deposits", ["currency_id"], name: "index_deposits_on_currency_id", using: :btree
  add_index "deposits", ["type"], name: "index_deposits_on_type", using: :btree

  create_table "markets", force: :cascade do |t|
    t.string   "ask_unit",      limit: 5,                                          null: false
    t.string   "bid_unit",      limit: 5,                                          null: false
    t.decimal  "ask_fee",                 precision: 17, scale: 16, default: 0.0,  null: false
    t.decimal  "bid_fee",                 precision: 17, scale: 16, default: 0.0,  null: false
    t.integer  "ask_precision", limit: 1,                           default: 4,    null: false
    t.integer  "bid_precision", limit: 1,                           default: 4,    null: false
    t.integer  "position",      limit: 4,                           default: 0,    null: false
    t.boolean  "visible",                                           default: true, null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
  end

  add_index "markets", ["ask_unit", "bid_unit"], name: "index_markets_on_ask_unit_and_bid_unit", unique: true, using: :btree
  add_index "markets", ["ask_unit"], name: "index_markets_on_ask_unit", using: :btree
  add_index "markets", ["bid_unit"], name: "index_markets_on_bid_unit", using: :btree
  add_index "markets", ["position"], name: "index_markets_on_position", using: :btree
  add_index "markets", ["visible"], name: "index_markets_on_visible", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "level",        limit: 20,  default: ""
    t.string   "sn",           limit: 12,                  null: false
    t.string   "email",        limit: 255,                 null: false
    t.boolean  "disabled",                 default: false, null: false
    t.boolean  "api_disabled",             default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "members", ["sn"], name: "index_members_on_sn", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "bid",            limit: 4
    t.integer  "ask",            limit: 4
    t.string   "market_id",      limit: 10
    t.decimal  "price",                      precision: 32, scale: 16
    t.decimal  "volume",                     precision: 32, scale: 16
    t.decimal  "origin_volume",              precision: 32, scale: 16
    t.decimal  "fee",                        precision: 32, scale: 16, default: 0.0, null: false
    t.integer  "state",          limit: 4
    t.datetime "done_at"
    t.string   "type",           limit: 8
    t.integer  "member_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sn",             limit: 255
    t.string   "source",         limit: 255,                                         null: false
    t.string   "ord_type",       limit: 10
    t.decimal  "locked",                     precision: 32, scale: 16
    t.decimal  "origin_locked",              precision: 32, scale: 16
    t.decimal  "funds_received",             precision: 32, scale: 16, default: 0.0
    t.integer  "trades_count",   limit: 4,                             default: 0
  end

  add_index "orders", ["market_id", "state"], name: "index_orders_on_market_id_and_state", using: :btree
  add_index "orders", ["member_id", "state"], name: "index_orders_on_member_id_and_state", using: :btree
  add_index "orders", ["member_id"], name: "index_orders_on_member_id", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree

  create_table "partial_trees", force: :cascade do |t|
    t.integer  "proof_id",   limit: 4,     null: false
    t.integer  "account_id", limit: 4,     null: false
    t.text     "json",       limit: 65535, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sum",        limit: 255
  end

  create_table "payment_addresses", force: :cascade do |t|
    t.integer  "account_id",  limit: 4
    t.string   "address",     limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id", limit: 4
    t.string   "secret",      limit: 255
    t.string   "details",     limit: 1024, default: "{}", null: false
  end

  add_index "payment_addresses", ["currency_id"], name: "index_payment_addresses_on_currency_id", using: :btree

  create_table "proofs", force: :cascade do |t|
    t.string   "root",        limit: 255
    t.integer  "currency_id", limit: 4
    t.boolean  "ready",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sum",         limit: 255
    t.text     "addresses",   limit: 65535
    t.string   "balance",     limit: 30
  end

  add_index "proofs", ["currency_id"], name: "index_proofs_on_currency_id", using: :btree

  create_table "trades", force: :cascade do |t|
    t.decimal  "price",                    precision: 32, scale: 16
    t.decimal  "volume",                   precision: 32, scale: 16
    t.integer  "ask_id",        limit: 4
    t.integer  "bid_id",        limit: 4
    t.integer  "trend",         limit: 4
    t.string   "market_id",     limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ask_member_id", limit: 4
    t.integer  "bid_member_id", limit: 4
    t.decimal  "funds",                    precision: 32, scale: 16
  end

  add_index "trades", ["ask_id"], name: "index_trades_on_ask_id", using: :btree
  add_index "trades", ["ask_member_id"], name: "index_trades_on_ask_member_id", using: :btree
  add_index "trades", ["bid_id"], name: "index_trades_on_bid_id", using: :btree
  add_index "trades", ["bid_member_id"], name: "index_trades_on_bid_member_id", using: :btree
  add_index "trades", ["created_at"], name: "index_trades_on_created_at", using: :btree
  add_index "trades", ["market_id"], name: "index_trades_on_market_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "withdraws", force: :cascade do |t|
    t.integer  "account_id",  limit: 4
    t.integer  "member_id",   limit: 4
    t.integer  "currency_id", limit: 4
    t.decimal  "amount",                  precision: 32, scale: 16
    t.decimal  "fee",                     precision: 32, scale: 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "done_at"
    t.string   "txid",        limit: 128
    t.string   "aasm_state",  limit: 255
    t.decimal  "sum",                     precision: 32, scale: 16, default: 0.0, null: false
    t.string   "type",        limit: 255
    t.string   "tid",         limit: 64,                                          null: false
    t.string   "rid",         limit: 64,                                          null: false
  end

  add_index "withdraws", ["currency_id"], name: "index_withdraws_on_currency_id", using: :btree

end
