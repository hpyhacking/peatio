module Withdraws
  class Fiat < Withdraw

  end
end

# == Schema Information
# Schema version: 20180501141718
#
# Table name: withdraws
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  member_id   :integer
#  currency_id :integer
#  amount      :decimal(32, 16)
#  fee         :decimal(32, 16)
#  created_at  :datetime
#  updated_at  :datetime
#  done_at     :datetime
#  txid        :string(128)
#  aasm_state  :string
#  sum         :decimal(32, 16)  default(0.0), not null
#  type        :string(255)
#  tid         :string(64)       not null
#  rid         :string(64)       not null
#
# Indexes
#
#  index_withdraws_on_currency_id  (currency_id)
#
