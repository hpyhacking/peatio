# encoding: UTF-8
# frozen_string_literal: true

class CaseSensitiveData < ActiveRecord::Migration
  def change
    execute %[ALTER TABLE deposits MODIFY address VARCHAR(64) BINARY;]
    execute %[ALTER TABLE deposits MODIFY txid VARCHAR(128) BINARY;]
    execute %[ALTER TABLE deposits MODIFY tid VARCHAR(64) BINARY NOT NULL;]
    execute %[ALTER TABLE withdraws MODIFY txid VARCHAR(128) BINARY;]
    execute %[ALTER TABLE payment_addresses MODIFY address VARCHAR(64) BINARY;]
    execute %[ALTER TABLE withdraws MODIFY tid VARCHAR(64) BINARY NOT NULL;]
    execute %[ALTER TABLE withdraws MODIFY rid VARCHAR(64) BINARY NOT NULL;]
  end
end
