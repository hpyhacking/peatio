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

ActiveRecord::Schema.define(version: 2020_03_17_080916) do

  create_table "accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "currency_id", limit: 10, null: false
    t.decimal "balance", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "locked", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id", "member_id"], name: "index_accounts_on_currency_id_and_member_id", unique: true
    t.index ["member_id"], name: "index_accounts_on_member_id"
  end

  create_table "adjustments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "reason", null: false
    t.text "description", null: false
    t.bigint "creator_id", null: false
    t.bigint "validator_id"
    t.decimal "amount", precision: 32, scale: 16, null: false
    t.integer "asset_account_code", limit: 2, null: false, unsigned: true
    t.string "receiving_account_number", limit: 64, null: false
    t.string "currency_id", null: false
    t.integer "category", limit: 1, null: false
    t.integer "state", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id", "state"], name: "index_adjustments_on_currency_id_and_state"
    t.index ["currency_id"], name: "index_adjustments_on_currency_id"
  end

  create_table "assets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "code", null: false
    t.string "currency_id", null: false
    t.string "reference_type"
    t.integer "reference_id"
    t.decimal "debit", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "credit", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_assets_on_currency_id"
    t.index ["reference_type", "reference_id"], name: "index_assets_on_reference_type_and_reference_id"
  end

  create_table "beneficiaries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "currency_id", limit: 10, null: false
    t.string "name", limit: 64, null: false
    t.string "description", default: ""
    t.json "data"
    t.integer "pin", limit: 3, null: false, unsigned: true
    t.integer "state", limit: 1, default: 0, null: false, unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_beneficiaries_on_currency_id"
    t.index ["member_id"], name: "index_beneficiaries_on_member_id"
  end

  create_table "blockchains", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "name"
    t.string "client", null: false
    t.string "server"
    t.bigint "height", null: false
    t.string "explorer_address"
    t.string "explorer_transaction"
    t.integer "min_confirmations", default: 6, null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_blockchains_on_key", unique: true
    t.index ["status"], name: "index_blockchains_on_status"
  end

  create_table "currencies", id: :string, limit: 10, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "blockchain_key", limit: 32
    t.string "symbol", limit: 1, null: false
    t.string "type", limit: 30, default: "coin", null: false
    t.decimal "deposit_fee", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "min_deposit_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "min_collection_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "withdraw_fee", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "min_withdraw_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "withdraw_limit_24h", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "withdraw_limit_72h", precision: 32, scale: 16, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.string "options", limit: 1000, default: "{}"
    t.boolean "visible", default: true, null: false
    t.boolean "deposit_enabled", default: true, null: false
    t.boolean "withdrawal_enabled", default: true, null: false
    t.bigint "base_factor", default: 1, null: false
    t.integer "precision", limit: 1, default: 8, null: false
    t.string "icon_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_currencies_on_position"
    t.index ["visible"], name: "index_currencies_on_visible"
  end

  create_table "deposits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "currency_id", limit: 10, null: false
    t.decimal "amount", precision: 32, scale: 16, null: false
    t.decimal "fee", precision: 32, scale: 16, null: false
    t.string "address", limit: 95
    t.string "txid", limit: 128, collation: "utf8_bin"
    t.integer "txout"
    t.string "aasm_state", limit: 30, null: false
    t.integer "block_number"
    t.string "type", limit: 30, null: false
    t.string "tid", limit: 64, null: false, collation: "utf8_bin"
    t.string "spread", limit: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.index ["aasm_state", "member_id", "currency_id"], name: "index_deposits_on_aasm_state_and_member_id_and_currency_id"
    t.index ["currency_id", "txid", "txout"], name: "index_deposits_on_currency_id_and_txid_and_txout", unique: true
    t.index ["currency_id"], name: "index_deposits_on_currency_id"
    t.index ["member_id", "txid"], name: "index_deposits_on_member_id_and_txid"
    t.index ["tid"], name: "index_deposits_on_tid"
    t.index ["type"], name: "index_deposits_on_type"
  end

  create_table "expenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "code", null: false
    t.string "currency_id", null: false
    t.string "reference_type"
    t.integer "reference_id"
    t.decimal "debit", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "credit", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_expenses_on_currency_id"
    t.index ["reference_type", "reference_id"], name: "index_expenses_on_reference_type_and_reference_id"
  end

  create_table "liabilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "code", null: false
    t.string "currency_id", null: false
    t.integer "member_id"
    t.string "reference_type"
    t.integer "reference_id"
    t.decimal "debit", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "credit", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_liabilities_on_currency_id"
    t.index ["member_id"], name: "index_liabilities_on_member_id"
    t.index ["reference_type", "reference_id"], name: "index_liabilities_on_reference_type_and_reference_id"
  end

  create_table "markets", id: :string, limit: 20, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "base_unit", limit: 10, null: false
    t.string "quote_unit", limit: 10, null: false
    t.integer "amount_precision", limit: 1, default: 4, null: false
    t.integer "price_precision", limit: 1, default: 4, null: false
    t.decimal "min_price", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "max_price", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "min_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.string "data_encrypted", limit: 1024
    t.string "state", limit: 32, default: "enabled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_unit", "quote_unit"], name: "index_markets_on_base_unit_and_quote_unit", unique: true
    t.index ["base_unit"], name: "index_markets_on_base_unit"
    t.index ["position"], name: "index_markets_on_position"
    t.index ["quote_unit"], name: "index_markets_on_quote_unit"
  end

  create_table "members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uid", limit: 32, null: false
    t.string "email", null: false
    t.integer "level", null: false
    t.string "role", limit: 16, null: false
    t.string "group", limit: 32, default: "vip-0", null: false
    t.string "state", limit: 16, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
  end

  create_table "operations_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "code", limit: 3, null: false
    t.string "type", limit: 10, null: false
    t.string "kind", limit: 30, null: false
    t.string "currency_type", limit: 10, null: false
    t.string "description", limit: 100
    t.string "scope", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_operations_accounts_on_code", unique: true
    t.index ["currency_type"], name: "index_operations_accounts_on_currency_type"
    t.index ["scope"], name: "index_operations_accounts_on_scope"
    t.index ["type", "kind", "currency_type"], name: "index_operations_accounts_on_type_and_kind_and_currency_type", unique: true
    t.index ["type"], name: "index_operations_accounts_on_type"
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.binary "uuid", limit: 16, null: false
    t.string "bid", limit: 10, null: false
    t.string "ask", limit: 10, null: false
    t.string "market_id", limit: 20, null: false
    t.decimal "price", precision: 32, scale: 16
    t.decimal "volume", precision: 32, scale: 16, null: false
    t.decimal "origin_volume", precision: 32, scale: 16, null: false
    t.decimal "maker_fee", precision: 17, scale: 16, default: "0.0", null: false
    t.decimal "taker_fee", precision: 17, scale: 16, default: "0.0", null: false
    t.integer "state", null: false
    t.string "type", limit: 8, null: false
    t.integer "member_id", null: false
    t.string "ord_type", limit: 30, null: false
    t.decimal "locked", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "origin_locked", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "funds_received", precision: 32, scale: 16, default: "0.0"
    t.integer "trades_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_orders_on_member_id"
    t.index ["state"], name: "index_orders_on_state"
    t.index ["type", "market_id"], name: "index_orders_on_type_and_market_id"
    t.index ["type", "member_id"], name: "index_orders_on_type_and_member_id"
    t.index ["type", "state", "market_id"], name: "index_orders_on_type_and_state_and_market_id"
    t.index ["type", "state", "member_id"], name: "index_orders_on_type_and_state_and_member_id"
    t.index ["updated_at"], name: "index_orders_on_updated_at"
  end

  create_table "payment_addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "currency_id", limit: 10, null: false
    t.integer "account_id", null: false
    t.string "address", limit: 95
    t.string "secret_encrypted"
    t.string "details_encrypted", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id", "address"], name: "index_payment_addresses_on_currency_id_and_address", unique: true
  end

  create_table "revenues", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "code", null: false
    t.string "currency_id", null: false
    t.integer "member_id"
    t.string "reference_type"
    t.integer "reference_id"
    t.decimal "debit", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "credit", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_revenues_on_currency_id"
    t.index ["reference_type", "reference_id"], name: "index_revenues_on_reference_type_and_reference_id"
  end

  create_table "trades", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.decimal "price", precision: 32, scale: 16, null: false
    t.decimal "amount", precision: 32, scale: 16, null: false
    t.decimal "total", precision: 32, scale: 16, default: "0.0", null: false
    t.integer "maker_order_id", null: false
    t.integer "taker_order_id", null: false
    t.string "market_id", limit: 20, null: false
    t.integer "maker_id", null: false
    t.integer "taker_id", null: false
    t.string "taker_type", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_trades_on_created_at"
    t.index ["maker_id", "taker_id"], name: "index_trades_on_maker_id_and_taker_id"
    t.index ["maker_order_id"], name: "index_trades_on_maker_order_id"
    t.index ["market_id", "created_at"], name: "index_trades_on_market_id_and_created_at"
    t.index ["taker_order_id"], name: "index_trades_on_taker_order_id"
  end

  create_table "trading_fees", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "market_id", limit: 20, default: "any", null: false
    t.string "group", limit: 32, default: "any", null: false
    t.decimal "maker", precision: 7, scale: 6, default: "0.0", null: false
    t.decimal "taker", precision: 7, scale: 6, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group"], name: "index_trading_fees_on_group"
    t.index ["market_id", "group"], name: "index_trading_fees_on_market_id_and_group", unique: true
    t.index ["market_id"], name: "index_trading_fees_on_market_id"
  end

  create_table "transfers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", limit: 30, null: false
    t.integer "category", limit: 1, null: false
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_transfers_on_key", unique: true
  end

  create_table "triggers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "order_type", limit: 1, null: false, unsigned: true
    t.binary "value", limit: 128, null: false
    t.integer "state", limit: 1, default: 0, null: false, unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_triggers_on_order_id"
    t.index ["order_type"], name: "index_triggers_on_order_type"
    t.index ["state"], name: "index_triggers_on_state"
  end

  create_table "wallets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "blockchain_key", limit: 32
    t.string "currency_id", limit: 10
    t.string "name", limit: 64
    t.string "address", null: false
    t.integer "kind", null: false
    t.string "gateway", limit: 20, default: "", null: false
    t.string "settings_encrypted", limit: 1024
    t.decimal "max_balance", precision: 32, scale: 16, default: "0.0", null: false
    t.string "status", limit: 32
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_wallets_on_currency_id"
    t.index ["kind", "currency_id", "status"], name: "index_wallets_on_kind_and_currency_id_and_status"
    t.index ["kind"], name: "index_wallets_on_kind"
    t.index ["status"], name: "index_wallets_on_status"
  end

  create_table "withdraws", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "member_id", null: false
    t.bigint "beneficiary_id"
    t.string "currency_id", limit: 10, null: false
    t.decimal "amount", precision: 32, scale: 16, null: false
    t.decimal "fee", precision: 32, scale: 16, null: false
    t.string "txid", limit: 128, collation: "utf8_bin"
    t.string "aasm_state", limit: 30, null: false
    t.integer "block_number"
    t.decimal "sum", precision: 32, scale: 16, null: false
    t.string "type", limit: 30, null: false
    t.string "tid", limit: 64, null: false, collation: "utf8_bin"
    t.string "rid", limit: 95, null: false
    t.string "note", limit: 256
    t.json "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.index ["aasm_state"], name: "index_withdraws_on_aasm_state"
    t.index ["currency_id", "txid"], name: "index_withdraws_on_currency_id_and_txid", unique: true
    t.index ["currency_id"], name: "index_withdraws_on_currency_id"
    t.index ["member_id"], name: "index_withdraws_on_member_id"
    t.index ["tid"], name: "index_withdraws_on_tid"
    t.index ["type"], name: "index_withdraws_on_type"
  end

end
