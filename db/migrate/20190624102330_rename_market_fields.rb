class RenameMarketFields < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        # ask_unit, bid_unit
        rename_column :markets, :ask_unit, :base_unit if column_exists?(:markets, :ask_unit)
        rename_column :markets, :bid_unit, :quote_unit if column_exists?(:markets, :bid_unit)

        # ask_precision, bid_precision
        change_column :markets, :ask_precision, :integer, default: 4, limit: 1, after: :quote_unit if column_exists?(:markets, :ask_precision)
        change_column :markets, :bid_precision, :integer, default: 4, limit: 1, after: :ask_precision if column_exists?(:markets, :bid_precision)

        rename_column :markets, :ask_precision, :amount_precision if column_exists?(:markets, :ask_precision)
        rename_column :markets, :bid_precision, :price_precision if column_exists?(:markets, :bid_precision)

        # min_ask_price, max_bid_price
        rename_column :markets, :min_ask_price, :min_price if column_exists?(:markets, :min_ask_price)
        rename_column :markets, :max_bid_price, :max_price if column_exists?(:markets, :max_bid_price)

        # min_ask_amount, min_bid_amount
        rename_column :markets, :min_ask_amount, :min_amount if column_exists?(:markets, :min_ask_amount)
        remove_column :markets, :min_bid_amount if column_exists?(:markets, :min_bid_amount)

        if column_exists?(:markets, :enabled)
          add_column :markets, :state, :string, limit: 32, default: :enabled, null: false, after: :position
          Market.find_each do |m|
            m.update_attribute(:state, m.enabled ? :enabled : :disabled)
          end
          remove_column :markets, :enabled
        end
      end

      dir.down do
        # ask_unit, bid_unit
        rename_column :markets, :base_unit, :ask_unit if column_exists?(:markets, :base_unit)
        rename_column :markets, :quote_unit, :bid_unit if column_exists?(:markets, :quote_unit)

        # ask_precision, bid_precision
        change_column :markets, :amount_precision, :integer, default: 8, limit: 1, after: :min_amount if column_exists?(:markets, :amount_precision)
        change_column :markets, :price_precision, :integer, default: 8, limit: 1, after: :amount_precision if column_exists?(:markets, :price_precision)

        rename_column :markets, :amount_precision, :ask_precision if column_exists?(:markets, :amount_precision)
        rename_column :markets, :price_precision, :bid_precision if column_exists?(:markets, :price_precision)

        # min_ask_price, max_bid_price
        rename_column :markets, :min_price, :min_ask_price if column_exists?(:markets, :min_price)
        rename_column :markets, :max_price, :max_bid_price if column_exists?(:markets, :max_price)

        # min_ask_amount, min_bid_amount
        rename_column :markets, :min_amount, :min_ask_amount if column_exists?(:markets, :min_amount)
        unless column_exists?(:markets, :min_bid_amount)
          add_column :markets, :min_bid_amount, :decimal,
                     precision: 32, scale: 16, default: 0.0, null: false, after: :min_ask_amount
        end

        if column_exists?(:markets, :state)
          add_column :markets, :enabled, :boolean, default: true, null: false, after: :position
          Market.find_each do |m|
            m.update_attribute(:enabled, m.state == 'enabled')
          end
          remove_column :markets, :state
        end
      end
    end
  end
end

# == BEFORE ==
# == Schema Information
# Schema version: 20190116140939
#
# Table name: markets
#
#  id             :string(20)       not null, primary key
#  ask_unit       :string(10)       not null
#  bid_unit       :string(10)       not null
#  ask_fee        :decimal(17, 16)  default(0.0), not null
#  bid_fee        :decimal(17, 16)  default(0.0), not null
#  min_ask_price  :decimal(32, 16)  default(0.0), not null
#  max_bid_price  :decimal(32, 16)  default(0.0), not null
#  min_ask_amount :decimal(32, 16)  default(0.0), not null
#  min_bid_amount :decimal(32, 16)  default(0.0), not null
#  ask_precision  :integer          default(8), not null
#  bid_precision  :integer          default(8), not null
#  position       :integer          default(0), not null
#  enabled        :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_markets_on_ask_unit               (ask_unit)
#  index_markets_on_ask_unit_and_bid_unit  (ask_unit,bid_unit) UNIQUE
#  index_markets_on_bid_unit               (bid_unit)
#  index_markets_on_enabled                (enabled)
#  index_markets_on_position               (position)
#

# == AFTER ==
# == Schema Information
# Schema version: 20190624102330
#
# Table name: markets
#
#  id               :string(20)       not null, primary key
#  base_unit        :string(10)       not null
#  quote_unit       :string(10)       not null
#  amount_precision :integer          default(4), not null
#  price_precision  :integer          default(4), not null
#  ask_fee          :decimal(17, 16)  default(0.0), not null
#  bid_fee          :decimal(17, 16)  default(0.0), not null
#  min_price        :decimal(32, 16)  default(0.0), not null
#  max_price        :decimal(32, 16)  default(0.0), not null
#  min_amount       :decimal(32, 16)  default(0.0), not null
#  position         :integer          default(0), not null
#  state            :string(32)       default("enabled"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_markets_on_base_unit                 (base_unit)
#  index_markets_on_base_unit_and_quote_unit  (base_unit,quote_unit) UNIQUE
#  index_markets_on_position                  (position)
#  index_markets_on_quote_unit                (quote_unit)
#
