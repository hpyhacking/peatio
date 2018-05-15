# encoding: UTF-8
# frozen_string_literal: true

class InitSchema < ActiveRecord::Migration
  def up
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
      t.integer  "currency",        limit: 4
      t.integer  "fun",             limit: 4
    end
    add_index "account_versions", ["account_id", "reason"], name: "index_account_versions_on_account_id_and_reason", using: :btree
    add_index "account_versions", ["account_id"], name: "index_account_versions_on_account_id", using: :btree
    add_index "account_versions", ["member_id", "reason"], name: "index_account_versions_on_member_id_and_reason", using: :btree
    add_index "account_versions", ["modifiable_id", "modifiable_type"], name: "index_account_versions_on_modifiable_id_and_modifiable_type", using: :btree
    create_table "accounts", force: :cascade do |t|
      t.integer  "member_id",                       limit: 4
      t.integer  "currency",                        limit: 4
      t.decimal  "balance",                                   precision: 32, scale: 16
      t.decimal  "locked",                                    precision: 32, scale: 16
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "in",                                        precision: 32, scale: 16
      t.decimal  "out",                                       precision: 32, scale: 16
      t.integer  "default_withdraw_fund_source_id", limit: 4
    end
    add_index "accounts", ["member_id", "currency"], name: "index_accounts_on_member_id_and_currency", using: :btree
    add_index "accounts", ["member_id"], name: "index_accounts_on_member_id", using: :btree
    create_table "api_tokens", force: :cascade do |t|
      t.integer  "member_id",       limit: 4,   null: false
      t.string   "access_key",      limit: 50,  null: false
      t.string   "secret_key",      limit: 50,  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "trusted_ip_list", limit: 255
      t.string   "label",           limit: 255
      t.datetime "expires_at"
      t.string   "scopes",          limit: 255
      t.datetime "deleted_at"
    end
    add_index "api_tokens", ["access_key"], name: "index_api_tokens_on_access_key", unique: true, using: :btree
    add_index "api_tokens", ["secret_key"], name: "index_api_tokens_on_secret_key", unique: true, using: :btree
    create_table "assets", force: :cascade do |t|
      t.string  "type",            limit: 255
      t.integer "attachable_id",   limit: 4
      t.string  "attachable_type", limit: 255
      t.string  "file",            limit: 255
    end
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
      t.string   "secret",     limit: 255
      t.integer  "member_id",  limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "nickname",   limit: 255
    end
    add_index "authentications", ["member_id"], name: "index_authentications_on_member_id", using: :btree
    add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", using: :btree
    create_table "deposits", force: :cascade do |t|
      t.integer  "account_id",             limit: 4
      t.integer  "member_id",              limit: 4
      t.integer  "currency",               limit: 4
      t.decimal  "amount",                             precision: 32, scale: 16
      t.decimal  "fee",                                precision: 32, scale: 16
      t.string   "fund_uid",               limit: 255
      t.string   "fund_extra",             limit: 255
      t.string   "txid",                   limit: 255
      t.integer  "state",                  limit: 4
      t.string   "aasm_state",             limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "done_at"
      t.string   "confirmations",          limit: 255
      t.string   "type",                   limit: 255
      t.integer  "payment_transaction_id", limit: 4
      t.integer  "txout",                  limit: 4
    end
    add_index "deposits", ["txid", "txout"], name: "index_deposits_on_txid_and_txout", using: :btree
    create_table "fund_sources", force: :cascade do |t|
      t.integer  "member_id",  limit: 4
      t.integer  "currency",   limit: 4
      t.string   "extra",      limit: 255
      t.string   "uid",        limit: 255
      t.boolean  "is_locked",              default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
    end
    create_table "id_documents", force: :cascade do |t|
      t.integer  "id_document_type",   limit: 4
      t.string   "name",               limit: 255
      t.string   "id_document_number", limit: 255
      t.integer  "member_id",          limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.date     "birth_date"
      t.text     "address",            limit: 65535
      t.string   "city",               limit: 255
      t.string   "country",            limit: 255
      t.string   "zipcode",            limit: 255
      t.integer  "id_bill_type",       limit: 4
      t.string   "aasm_state",         limit: 255
    end
    create_table "members", force: :cascade do |t|
      t.string   "sn",           limit: 255
      t.string   "email",        limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "disabled",                 default: false
      t.boolean  "api_disabled",             default: false
      t.string   "nickname",     limit: 255
    end
    create_table "orders", force: :cascade do |t|
      t.integer  "bid",            limit: 4
      t.integer  "ask",            limit: 4
      t.integer  "currency",       limit: 4
      t.decimal  "price",                      precision: 32, scale: 16
      t.decimal  "volume",                     precision: 32, scale: 16
      t.decimal  "origin_volume",              precision: 32, scale: 16
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
    add_index "orders", ["currency", "state"], name: "index_orders_on_currency_and_state", using: :btree
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
      t.integer  "account_id", limit: 4
      t.string   "address",    limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "currency",   limit: 4
      t.string   "secret",     limit: 255
    end
    create_table "payment_transactions", force: :cascade do |t|
      t.string   "txid",          limit: 255
      t.decimal  "amount",                    precision: 32, scale: 16
      t.integer  "confirmations", limit: 4
      t.string   "address",       limit: 255
      t.integer  "state",         limit: 4
      t.string   "aasm_state",    limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "receive_at"
      t.datetime "dont_at"
      t.integer  "currency",      limit: 4
      t.string   "type",          limit: 60
      t.integer  "txout",         limit: 4
    end
    add_index "payment_transactions", ["txid", "txout"], name: "index_payment_transactions_on_txid_and_txout", using: :btree
    add_index "payment_transactions", ["type"], name: "index_payment_transactions_on_type", using: :btree
    create_table "proofs", force: :cascade do |t|
      t.string   "root",       limit: 255
      t.integer  "currency",   limit: 4
      t.boolean  "ready",                    default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "sum",        limit: 255
      t.text     "addresses",  limit: 65535
      t.string   "balance",    limit: 30
    end
    create_table "trades", force: :cascade do |t|
      t.decimal  "price",                   precision: 32, scale: 16
      t.decimal  "volume",                  precision: 32, scale: 16
      t.integer  "ask_id",        limit: 4
      t.integer  "bid_id",        limit: 4
      t.integer  "trend",         limit: 4
      t.integer  "currency",      limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "ask_member_id", limit: 4
      t.integer  "bid_member_id", limit: 4
      t.decimal  "funds",                   precision: 32, scale: 16
    end
    add_index "trades", ["ask_id"], name: "index_trades_on_ask_id", using: :btree
    add_index "trades", ["ask_member_id"], name: "index_trades_on_ask_member_id", using: :btree
    add_index "trades", ["bid_id"], name: "index_trades_on_bid_id", using: :btree
    add_index "trades", ["bid_member_id"], name: "index_trades_on_bid_member_id", using: :btree
    add_index "trades", ["created_at"], name: "index_trades_on_created_at", using: :btree
    add_index "trades", ["currency"], name: "index_trades_on_currency", using: :btree
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
      t.string   "sn",         limit: 255
      t.integer  "account_id", limit: 4
      t.integer  "member_id",  limit: 4
      t.integer  "currency",   limit: 4
      t.decimal  "amount",                 precision: 32, scale: 16
      t.decimal  "fee",                    precision: 32, scale: 16
      t.string   "fund_uid",   limit: 255
      t.string   "fund_extra", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "done_at"
      t.string   "txid",       limit: 255
      t.string   "aasm_state", limit: 255
      t.decimal  "sum",                    precision: 32, scale: 16, default: 0.0, null: false
      t.string   "type",       limit: 255
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
