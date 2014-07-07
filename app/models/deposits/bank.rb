# == Schema Information
#
# Table name: deposits
#
#  id         :integer          not null, primary key
#  account_id :integer
#  member_id  :integer
#  currency   :integer
#  amount     :decimal(32, 16)
#  fee        :decimal(32, 16)
#  fund_uid   :string(255)
#  fund_extra :string(255)
#  txid       :string(255)
#  state      :integer
#  aasm_state :string(255)
#  created_at :datetime
#  updated_at :datetime
#  done_at    :datetime
#  memo       :string(255)
#  type       :string(255)
#

module Deposits
  class Bank < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable
  end
end
