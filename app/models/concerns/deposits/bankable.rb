module Deposits
  module Bankable
    extend ActiveSupport::Concern

    included do
      attr_accessor :holder, :remember

      validates_presence_of :fund_extra, :fund_uid, :amount

      delegate :accounts, to: :channel

      enumerize :fund_extra, in: channel.banks, scope: true, i18n_scope: 'banks'
    end
  end
end
