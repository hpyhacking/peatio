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

ActiveRecord::Schema.define(version: 20190225171726) do

  create_table "accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "member_id",                                                        null: false
    t.string   "currency_id", limit: 10,                                           null: false
    t.decimal  "balance",                precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "locked",                 precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.index ["currency_id", "member_id"], name: "index_accounts_on_currency_id_and_member_id", unique: true, using: :btree
    t.index ["member_id"], name: "index_accounts_on_member_id", using: :btree
  end

  create_table "assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "code",                                                     null: false
    t.string   "currency_id",                                              null: false
    t.string   "reference_type"
    t.integer  "reference_id"
    t.decimal  "debit",          precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "credit",         precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["currency_id"], name: "index_assets_on_currency_id", using: :btree
    t.index ["reference_type", "reference_id"], name: "index_assets_on_reference_type_and_reference_id", using: :btree
  end

  create_table "blockchains", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "key",                              null: false
    t.string   "name"
    t.string   "client",                           null: false
    t.string   "server"
    t.integer  "height",                           null: false
    t.string   "explorer_address"
    t.string   "explorer_transaction"
    t.integer  "min_confirmations",    default: 6, null: false
    t.string   "status",                           null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["key"], name: "index_blockchains_on_key", unique: true, using: :btree
    t.index ["status"], name: "index_blockchains_on_status", using: :btree
  end

  create_table "currencies", id: :string, limit: 10, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "blockchain_key",        limit: 32
    t.string   "symbol",                limit: 1,                                               null: false
    t.string   "type",                  limit: 30,                             default: "coin", null: false
    t.decimal  "deposit_fee",                        precision: 32, scale: 16, default: "0.0",  null: false
    t.decimal  "min_deposit_amount",                 precision: 32, scale: 16, default: "0.0",  null: false
    t.decimal  "min_collection_amount",              precision: 32, scale: 16, default: "0.0",  null: false
    t.decimal  "withdraw_fee",                       precision: 32, scale: 16, default: "0.0",  null: false
    t.decimal  "min_withdraw_amount",                precision: 32, scale: 16, default: "0.0",  null: false
    t.decimal  "withdraw_limit_24h",                 precision: 32, scale: 16, default: "0.0",  null: false
    t.decimal  "withdraw_limit_72h",                 precision: 32, scale: 16, default: "0.0",  null: false
    t.integer  "position",                                                     default: 0,      null: false
    t.string   "options",               limit: 1000,                           default: "{}"
    t.boolean  "enabled",                                                      default: true,   null: false
    t.bigint   "base_factor",                                                  default: 1,      null: false
    t.integer  "precision",             limit: 1,                              default: 8,      null: false
    t.string   "icon_url"
    t.datetime "created_at",                                                                    null: false
    t.datetime "updated_at",                                                                    null: false
    t.index ["enabled"], name: "index_currencies_on_enabled", using: :btree
    t.index ["enabled"], name: "index_currencies_on_enabled_and_code", using: :btree
    t.index ["position"], name: "index_currencies_on_position", using: :btree
  end

  create_table "deposits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "member_id",                                          null: false
    t.string   "currency_id",  limit: 10,                            null: false
    t.decimal  "amount",                   precision: 32, scale: 16, null: false
    t.decimal  "fee",                      precision: 32, scale: 16, null: false
    t.string   "address",      limit: 95
    t.string   "txid",         limit: 128,                                        collation: "utf8_bin"
    t.integer  "txout"
    t.string   "aasm_state",   limit: 30,                            null: false
    t.integer  "block_number"
    t.string   "type",         limit: 30,                            null: false
    t.string   "tid",          limit: 64,                            null: false, collation: "utf8_bin"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.datetime "completed_at"
    t.index ["aasm_state", "member_id", "currency_id"], name: "index_deposits_on_aasm_state_and_member_id_and_currency_id", using: :btree
    t.index ["currency_id", "txid", "txout"], name: "index_deposits_on_currency_id_and_txid_and_txout", unique: true, using: :btree
    t.index ["currency_id"], name: "index_deposits_on_currency_id", using: :btree
    t.index ["member_id", "txid"], name: "index_deposits_on_member_id_and_txid", using: :btree
    t.index ["tid"], name: "index_deposits_on_tid", using: :btree
    t.index ["type"], name: "index_deposits_on_type", using: :btree
  end

  create_table "expenses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "code",                                                     null: false
    t.string   "currency_id",                                              null: false
    t.string   "reference_type"
    t.integer  "reference_id"
    t.decimal  "debit",          precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "credit",         precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["currency_id"], name: "index_expenses_on_currency_id", using: :btree
    t.index ["reference_type", "reference_id"], name: "index_expenses_on_reference_type_and_reference_id", using: :btree
  end

  create_table "liabilities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "code",                                                     null: false
    t.string   "currency_id",                                              null: false
    t.integer  "member_id"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.decimal  "debit",          precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "credit",         precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["currency_id"], name: "index_liabilities_on_currency_id", using: :btree
    t.index ["member_id"], name: "index_liabilities_on_member_id", using: :btree
    t.index ["reference_type", "reference_id"], name: "index_liabilities_on_reference_type_and_reference_id", using: :btree
  end

  create_table "markets", id: :string, limit: 20, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "ask_unit",       limit: 10,                                           null: false
    t.string   "bid_unit",       limit: 10,                                           null: false
    t.decimal  "ask_fee",                   precision: 17, scale: 16, default: "0.0", null: false
    t.decimal  "bid_fee",                   precision: 17, scale: 16, default: "0.0", null: false
    t.decimal  "min_ask_price",             precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "max_bid_price",             precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "min_ask_amount",            precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "min_bid_amount",            precision: 32, scale: 16, default: "0.0", null: false
    t.integer  "ask_precision",  limit: 1,                            default: 8,     null: false
    t.integer  "bid_precision",  limit: 1,                            default: 8,     null: false
    t.integer  "position",                                            default: 0,     null: false
    t.boolean  "enabled",                                             default: true,  null: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.index ["ask_unit", "bid_unit"], name: "index_markets_on_ask_unit_and_bid_unit", unique: true, using: :btree
    t.index ["ask_unit"], name: "index_markets_on_ask_unit", using: :btree
    t.index ["bid_unit"], name: "index_markets_on_bid_unit", using: :btree
    t.index ["enabled"], name: "index_markets_on_enabled", using: :btree
    t.index ["position"], name: "index_markets_on_position", using: :btree
  end

  create_table "members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uid",        limit: 12, null: false
    t.string   "email",                 null: false
    t.integer  "level",                 null: false
    t.string   "role",       limit: 16, null: false
    t.string   "state",      limit: 16, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["email"], name: "index_members_on_email", unique: true, using: :btree
  end

  create_table "operations_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "code",          limit: 3,   null: false
    t.string   "type",          limit: 10,  null: false
    t.string   "kind",          limit: 30,  null: false
    t.string   "currency_type", limit: 10,  null: false
    t.string   "description",   limit: 100
    t.string   "scope",         limit: 10,  null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["code"], name: "index_operations_accounts_on_code", unique: true, using: :btree
    t.index ["currency_type"], name: "index_operations_accounts_on_currency_type", using: :btree
    t.index ["scope"], name: "index_operations_accounts_on_scope", using: :btree
    t.index ["type", "kind", "currency_type"], name: "index_operations_accounts_on_type_and_kind_and_currency_type", unique: true, using: :btree
    t.index ["type"], name: "index_operations_accounts_on_type", using: :btree
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "bid",            limit: 10,                                           null: false
    t.string   "ask",            limit: 10,                                           null: false
    t.string   "market_id",      limit: 20,                                           null: false
    t.decimal  "price",                     precision: 32, scale: 16
    t.decimal  "volume",                    precision: 32, scale: 16,                 null: false
    t.decimal  "origin_volume",             precision: 32, scale: 16,                 null: false
    t.decimal  "fee",                       precision: 32, scale: 16, default: "0.0", null: false
    t.integer  "state",                                                               null: false
    t.string   "type",           limit: 8,                                            null: false
    t.integer  "member_id",                                                           null: false
    t.string   "ord_type",       limit: 30,                                           null: false
    t.decimal  "locked",                    precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "origin_locked",             precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "funds_received",            precision: 32, scale: 16, default: "0.0"
    t.integer  "trades_count",                                        default: 0,     null: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.index ["member_id"], name: "index_orders_on_member_id", using: :btree
    t.index ["state"], name: "index_orders_on_state", using: :btree
    t.index ["type", "market_id"], name: "index_orders_on_type_and_market_id", using: :btree
    t.index ["type", "member_id"], name: "index_orders_on_type_and_member_id", using: :btree
    t.index ["type", "state", "market_id"], name: "index_orders_on_type_and_state_and_market_id", using: :btree
    t.index ["type", "state", "member_id"], name: "index_orders_on_type_and_state_and_member_id", using: :btree
    t.index ["updated_at"], name: "index_orders_on_updated_at", using: :btree
  end

  create_table "payment_addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "currency_id", limit: 10,                  null: false
    t.integer  "account_id",                              null: false
    t.string   "address",     limit: 95
    t.string   "secret",      limit: 128
    t.string   "details",     limit: 1024, default: "{}", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["currency_id", "address"], name: "index_payment_addresses_on_currency_id_and_address", unique: true, using: :btree
  end

  create_table "revenues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "code",                                                     null: false
    t.string   "currency_id",                                              null: false
    t.integer  "member_id"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.decimal  "debit",          precision: 32, scale: 16, default: "0.0", null: false
    t.decimal  "credit",         precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["currency_id"], name: "index_revenues_on_currency_id", using: :btree
    t.index ["reference_type", "reference_id"], name: "index_revenues_on_reference_type_and_reference_id", using: :btree
  end

  create_table "trades", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal  "price",                    precision: 32, scale: 16, null: false
    t.decimal  "volume",                   precision: 32, scale: 16, null: false
    t.integer  "ask_id",                                             null: false
    t.integer  "bid_id",                                             null: false
    t.integer  "trend",                                              null: false
    t.string   "market_id",     limit: 20,                           null: false
    t.integer  "ask_member_id",                                      null: false
    t.integer  "bid_member_id",                                      null: false
    t.decimal  "funds",                    precision: 32, scale: 16, null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.index ["ask_id"], name: "index_trades_on_ask_id", using: :btree
    t.index ["ask_member_id", "bid_member_id"], name: "index_trades_on_ask_member_id_and_bid_member_id", using: :btree
    t.index ["bid_id"], name: "index_trades_on_bid_id", using: :btree
    t.index ["created_at"], name: "index_trades_on_created_at", using: :btree
    t.index ["market_id", "created_at"], name: "index_trades_on_market_id_and_created_at", using: :btree
  end

  create_table "transfers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "key",                                null: false
    t.string   "kind",       limit: 30,              null: false
    t.string   "desc",                  default: ""
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["key"], name: "index_transfers_on_key", unique: true, using: :btree
    t.index ["kind"], name: "index_transfers_on_kind", using: :btree
  end

  create_table "wallets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "blockchain_key", limit: 32
    t.string   "currency_id",    limit: 10
    t.string   "name",           limit: 64
    t.string   "address",                                                               null: false
    t.integer  "kind",                                                                  null: false
    t.integer  "nsig"
    t.string   "gateway",        limit: 20,                             default: "",    null: false
    t.string   "settings",       limit: 1000,                           default: "{}",  null: false
    t.decimal  "max_balance",                 precision: 32, scale: 16, default: "0.0", null: false
    t.integer  "parent"
    t.string   "status",         limit: 32
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.index ["currency_id"], name: "index_wallets_on_currency_id", using: :btree
    t.index ["kind", "currency_id", "status"], name: "index_wallets_on_kind_and_currency_id_and_status", using: :btree
    t.index ["kind"], name: "index_wallets_on_kind", using: :btree
    t.index ["status"], name: "index_wallets_on_status", using: :btree
  end

  create_table "withdraws", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id",                                         null: false
    t.integer  "member_id",                                          null: false
    t.string   "currency_id",  limit: 10,                            null: false
    t.decimal  "amount",                   precision: 32, scale: 16, null: false
    t.decimal  "fee",                      precision: 32, scale: 16, null: false
    t.string   "txid",         limit: 128,                                        collation: "utf8_bin"
    t.string   "aasm_state",   limit: 30,                            null: false
    t.integer  "block_number"
    t.decimal  "sum",                      precision: 32, scale: 16, null: false
    t.string   "type",         limit: 30,                            null: false
    t.string   "tid",          limit: 64,                            null: false, collation: "utf8_bin"
    t.string   "rid",          limit: 95,                            null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.datetime "completed_at"
    t.index ["aasm_state"], name: "index_withdraws_on_aasm_state", using: :btree
    t.index ["account_id"], name: "index_withdraws_on_account_id", using: :btree
    t.index ["currency_id", "txid"], name: "index_withdraws_on_currency_id_and_txid", unique: true, using: :btree
    t.index ["currency_id"], name: "index_withdraws_on_currency_id", using: :btree
    t.index ["member_id"], name: "index_withdraws_on_member_id", using: :btree
    t.index ["tid"], name: "index_withdraws_on_tid", using: :btree
    t.index ["type"], name: "index_withdraws_on_type", using: :btree
  end

end
