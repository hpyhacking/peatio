module Deposits
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates :fund_extra, :fund_uid, :amount, presence: true
      validate  { errors.add(:currency, :invalid) if currency && !currency.fiat? }
      delegate :accounts, to: :channel
    end
  end
end
