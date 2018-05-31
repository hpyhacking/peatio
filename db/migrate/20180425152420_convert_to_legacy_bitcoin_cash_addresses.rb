# encoding: UTF-8
# frozen_string_literal: true

class ConvertToLegacyBitcoinCashAddresses < ActiveRecord::Migration
  def change
    return unless defined?(PaymentAddress)
    return unless defined?(Currency)
    return unless table_exists?(:payment_addresses)
    return unless column_exists?(:payment_addresses, :address)
    return unless column_exists?(:payment_addresses, :currency_id)
    return unless column_exists?(:currencies, :id)
    return unless column_exists?(:currencies, :code)

    Currency.find_by_id(:bch).tap do |ccy|
      break unless ccy
      PaymentAddress.where(currency: ccy).find_each do |pa|
        next if pa.address.blank?
        pa.update_columns(address: CashAddr::Converter.to_legacy_address(pa.address))
      end
    end
  end
end
