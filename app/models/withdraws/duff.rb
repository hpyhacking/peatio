module Withdraws
  class Duff < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
    include ::FundSourceable
  end
end

# == Schema Information
# Schema version: 20180227163417
#
# Table name: withdraws
#
#  id          :integer          not null, primary key
#  sn          :string(255)
#  account_id  :integer
#  member_id   :integer
#  currency_id :integer
#  amount      :decimal(32, 16)
#  fee         :decimal(32, 16)
#  fund_uid    :string(255)
#  fund_extra  :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  done_at     :datetime
#  txid        :string(255)
#  aasm_state  :string
#  sum         :decimal(32, 16)  default(0.0), not null
#  type        :string(255)
#
# Indexes
#
#  index_withdraws_on_currency_id  (currency_id)
#
