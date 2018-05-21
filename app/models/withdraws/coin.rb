# encoding: UTF-8
# frozen_string_literal: true

module Withdraws
  class Coin < Withdraw
    before_validation do
      next unless currency&.code&.bch? && rid?
      self.rid = CashAddr::Converter.to_legacy_address(rid)
    end

    before_validation do
      next unless currency&.case_insensitive?
      self.rid  = rid.try(:downcase)
      self.txid = txid.try(:downcase)
    end

    def wallet_url
      if currency.wallet_url_template?
        currency.wallet_url_template.gsub('#{address}', rid)
      end
    end

    def transaction_url
      if txid? && currency.transaction_url_template?
        currency.transaction_url_template.gsub('#{txid}', txid)
      end
    end

    def audit!
      inspection = currency.api.inspect_address!(rid)

      if inspection[:is_valid] == false
        Rails.logger.info { "#{self.class.name}##{id} uses invalid address: #{rid.inspect}" }
        reject!
      else
        super
      end
    end

    def as_json(*)
      super.merge \
        wallet_url:      wallet_url,
        transaction_url: transaction_url
    end
  end
end

# == Schema Information
# Schema version: 20180517101842
#
# Table name: withdraws
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  member_id    :integer          not null
#  currency_id  :integer          not null
#  amount       :decimal(32, 16)  not null
#  fee          :decimal(32, 16)  not null
#  txid         :string(128)
#  aasm_state   :string(30)       not null
#  sum          :decimal(32, 16)  not null
#  type         :string(30)       not null
#  tid          :string(64)       not null
#  rid          :string(64)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_at :datetime
#
# Indexes
#
#  index_withdraws_on_aasm_state            (aasm_state)
#  index_withdraws_on_account_id            (account_id)
#  index_withdraws_on_currency_id           (currency_id)
#  index_withdraws_on_currency_id_and_txid  (currency_id,txid) UNIQUE
#  index_withdraws_on_member_id             (member_id)
#  index_withdraws_on_tid                   (tid)
#  index_withdraws_on_type                  (type)
#
