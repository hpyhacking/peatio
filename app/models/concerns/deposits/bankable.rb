module Deposits
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates :fund_extra, :fund_uid, :amount, presence: true
      validates_inclusion_of :currency, in: Currency.fiats.map(&:code)
      delegate :accounts, to: :channel
    end
  end
end
