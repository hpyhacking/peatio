class ReplaceIdToCode < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      execute %[ALTER TABLE `currencies` CHANGE `code` `code` VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL;]
      execute %[ALTER TABLE `currencies` CHANGE `id` `id` VARCHAR(10) NOT NULL;]
      %i[deposits withdraws payment_addresses accounts proofs].each do |t|
        change_column t, :currency_id, :string, limit: 10
        execute \
        %[UPDATE #{t}
          INNER JOIN currencies ON #{t}.currency_id = currencies.id
          SET #{t}.currency_id = currencies.code]
      end

      change_column :orders, :ask, :string, limit: 10
      execute \
        %[UPDATE orders
          INNER JOIN currencies ON orders.ask = currencies.id
          SET orders.ask = currencies.code]

      change_column :orders, :bid, :string, limit: 10
      execute \
        %[UPDATE orders
          INNER JOIN currencies ON orders.bid = currencies.id
          SET orders.bid = currencies.code]

      execute %[UPDATE `currencies` SET `id` = `code`;]
      execute %[ALTER TABLE `currencies` DROP `code`;]
      remove_index :currencies, column: %i[enabled code]
      add_index :currencies, [:enabled]
    end
  end
end
