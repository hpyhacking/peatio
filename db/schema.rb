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

ActiveRecord::Schema.define(version: 20140702035833) do

  create_table "account_versions", force: true do |t|
    t.integer  "member_id"
    t.integer  "account_id"
    t.integer  "reason"
    t.decimal  "balance",         precision: 32, scale: 16
    t.decimal  "locked",          precision: 32, scale: 16
    t.decimal  "fee",             precision: 32, scale: 16
    t.decimal  "amount",          precision: 32, scale: 16
    t.integer  "modifiable_id"
    t.string   "modifiable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency"
    t.integer  "fun"
  end

  add_index "account_versions", ["account_id", "reason"], name: "index_account_versions_on_account_id_and_reason", using: :btree
  add_index "account_versions", ["member_id", "reason"], name: "index_account_versions_on_member_id_and_reason", using: :btree
  add_index "account_versions", ["modifiable_id", "modifiable_type"], name: "index_account_versions_on_modifiable_id_and_modifiable_type", using: :btree

  create_table "accounts", force: true do |t|
    t.integer  "member_id"
    t.integer  "currency"
    t.decimal  "balance",    precision: 32, scale: 16
    t.decimal  "locked",     precision: 32, scale: 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "in",         precision: 32, scale: 16
    t.decimal  "out",        precision: 32, scale: 16
  end

  add_index "accounts", ["member_id", "currency"], name: "index_accounts_on_member_id_and_currency", using: :btree
  add_index "accounts", ["member_id"], name: "index_accounts_on_member_id", using: :btree

  create_table "api_tokens", force: true do |t|
    t.integer  "member_id",             null: false
    t.string   "access_key", limit: 50, null: false
    t.string   "secret_key", limit: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_tokens", ["access_key"], name: "index_api_tokens_on_access_key", unique: true, using: :btree
  add_index "api_tokens", ["secret_key"], name: "index_api_tokens_on_secret_key", unique: true, using: :btree

  create_table "authentications", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["member_id"], name: "index_authentications_on_member_id", using: :btree
  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", using: :btree

  create_table "deposits", force: true do |t|
    t.integer  "account_id"
    t.integer  "member_id"
    t.integer  "currency"
    t.decimal  "amount",     precision: 32, scale: 16
    t.decimal  "fee",        precision: 32, scale: 16
    t.string   "fund_uid"
    t.string   "fund_extra"
    t.string   "txid"
    t.integer  "state"
    t.string   "aasm_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "done_at"
    t.string   "memo"
    t.string   "type"
  end

  create_table "document_translations", force: true do |t|
    t.integer  "document_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "body"
    t.text     "desc"
    t.text     "keywords"
  end

  add_index "document_translations", ["document_id"], name: "index_document_translations_on_document_id", using: :btree
  add_index "document_translations", ["locale"], name: "index_document_translations_on_locale", using: :btree

  create_table "documents", force: true do |t|
    t.string   "key"
    t.string   "title"
    t.text     "body"
    t.boolean  "is_auth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "desc"
    t.text     "keywords"
  end

  create_table "dogecoin_trades", id: false, force: true do |t|
    t.datetime "created_at"
    t.decimal  "volume",     precision: 32, scale: 16
    t.integer  "member_id"
  end

  create_table "fund_sources", force: true do |t|
    t.integer  "member_id"
    t.integer  "currency"
    t.string   "extra"
    t.string   "uid"
    t.integer  "channel_id"
    t.boolean  "is_locked",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "id_documents", force: true do |t|
    t.integer  "category"
    t.string   "name"
    t.string   "sn"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified"
  end

  create_table "identities", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "is_active"
    t.integer  "retry_count"
    t.boolean  "is_locked"
    t.datetime "locked_at"
    t.datetime "last_verify_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.string   "sn"
    t.string   "name"
    t.string   "display_name"
    t.string   "email"
    t.integer  "identity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state"
    t.boolean  "activated"
    t.integer  "country_code"
    t.string   "phone_number"
    t.boolean  "phone_number_verified"
  end

  create_table "orders", force: true do |t|
    t.integer  "bid"
    t.integer  "ask"
    t.integer  "currency"
    t.decimal  "price",                    precision: 32, scale: 16
    t.decimal  "volume",                   precision: 32, scale: 16
    t.decimal  "origin_volume",            precision: 32, scale: 16
    t.integer  "state"
    t.datetime "done_at"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sn"
    t.string   "source",                                             null: false
    t.string   "type",          limit: 8
    t.string   "ord_type",      limit: 10
    t.decimal  "locked",                   precision: 32, scale: 16
    t.decimal  "origin_locked",            precision: 32, scale: 16
  end

  create_table "partial_trees", force: true do |t|
    t.integer  "proof_id",   null: false
    t.integer  "account_id", null: false
    t.text     "json",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sum"
  end

  create_table "payment_addresses", force: true do |t|
    t.integer  "account_id"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency"
  end

  create_table "payment_transactions", force: true do |t|
    t.string   "txid"
    t.decimal  "amount",        precision: 32, scale: 16
    t.integer  "confirmations"
    t.string   "address"
    t.integer  "state"
    t.string   "aasm_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "receive_at"
    t.datetime "dont_at"
    t.integer  "currency"
  end

  create_table "proofs", force: true do |t|
    t.string   "root"
    t.integer  "currency"
    t.boolean  "ready",                               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sum"
    t.text     "addresses"
    t.decimal  "balance",    precision: 10, scale: 0
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tokens", force: true do |t|
    t.string   "token"
    t.datetime "expire_at"
    t.integer  "member_id"
    t.boolean  "is_used"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["type", "token", "expire_at", "is_used"], name: "index_tokens_on_type_and_token_and_expire_at_and_is_used", using: :btree

  create_table "trades", force: true do |t|
    t.decimal  "price",         precision: 32, scale: 16
    t.decimal  "volume",        precision: 32, scale: 16
    t.integer  "ask_id"
    t.integer  "bid_id"
    t.integer  "trend"
    t.integer  "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ask_member_id"
    t.integer  "bid_member_id"
    t.decimal  "funds",         precision: 32, scale: 16
  end

  add_index "trades", ["ask_member_id"], name: "index_trades_on_ask_member_id", using: :btree
  add_index "trades", ["bid_member_id"], name: "index_trades_on_bid_member_id", using: :btree
  add_index "trades", ["currency"], name: "index_trades_on_currency", using: :btree

  create_table "two_factors", force: true do |t|
    t.integer  "member_id"
    t.string   "otp_secret"
    t.datetime "last_verify_at"
    t.boolean  "activated"
    t.string   "type"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "withdraws", force: true do |t|
    t.string   "sn"
    t.integer  "account_id"
    t.integer  "member_id"
    t.integer  "currency"
    t.decimal  "amount",     precision: 32, scale: 16
    t.decimal  "fee",        precision: 32, scale: 16
    t.string   "fund_uid"
    t.string   "fund_extra"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "done_at"
    t.string   "txid"
    t.string   "aasm_state"
    t.decimal  "sum",        precision: 32, scale: 16
    t.string   "type"
  end

end
