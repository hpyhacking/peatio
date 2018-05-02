module Deposits
  class Fiat < Deposit
    validate { errors.add(:currency, :invalid) if currency && !currency.fiat? }

    def charge!
      with_lock { accept! }
    end
  end
end

# == Schema Information
# Schema version: 20180501141718
#
# Table name: deposits
#
#  id            :integer          not null, primary key
#  member_id     :integer          not null
#  currency_id   :integer          not null
#  amount        :decimal(32, 16)  not null
#  fee           :decimal(32, 16)  not null
#  address       :string(64)
#  txid          :string(128)
#  txout         :integer
#  aasm_state    :string           not null
#  confirmations :integer          default(0), not null
#  type          :string(30)       not null
#  tid           :string(64)       not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  completed_at  :datetime
#
# Indexes
#
#  index_deposits_on_currency_id                     (currency_id)
#  index_deposits_on_currency_id_and_txid_and_txout  (currency_id,txid,txout) UNIQUE
#  index_deposits_on_type                            (type)
#
