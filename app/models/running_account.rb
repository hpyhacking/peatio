class RunningAccount < ActiveRecord::Base
  include Currencible

  CATEGORY = {
    withdraw_fee:         0,
    trading_fee:          1,
    register_reward:      2,
    referral_code_reward: 3,
    deposit_reward:       4
  }

  enumerize :category, in: CATEGORY

  belongs_to :member
  belongs_to :source, polymorphic: true

end
