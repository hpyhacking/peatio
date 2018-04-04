class WithdrawDestination
  class Coin < self
    nested_attr :address

    validates :address, presence: true

    class << self
      def fields
        super.merge!(address: 'Wallet address in blockchain.')
      end
    end
  end
end

# == Schema Information
# Schema version: 20180305111648
#
# Table name: withdraw_destinations
#
#  id          :integer          not null, primary key
#  type        :string(30)       not null
#  member_id   :integer          not null
#  currency_id :integer          not null
#  details     :string(4096)     default({}), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_withdraw_destinations_on_currency_id  (currency_id)
#  index_withdraw_destinations_on_member_id    (member_id)
#  index_withdraw_destinations_on_type         (type)
#
