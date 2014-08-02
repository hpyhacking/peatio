module Deposits
  module Bankable
    extend ActiveSupport::Concern

    included do
      attr_accessor :fund_source

      validates_presence_of :fund_extra, :fund_uid, :amount

      delegate :accounts, to: :channel
    end
  end
end
