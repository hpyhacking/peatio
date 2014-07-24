module Deposits
  module Bankable
    extend ActiveSupport::Concern

    included do
      attr_accessor :holder, :remember

      validates_presence_of :fund_extra, :fund_uid, :amount

      delegate :receive_fund_holder_text, :receive_fund_uid_text, :receive_fund_extra_text, to: :channel

      enumerize :fund_extra, in: channel.banks, scope: true, i18n_scope: 'banks'
    end

    module ClassMethods
      def bank_hash
        enumerized_attributes['fund_extra'].options.inject({}) {|k, v| k[v[1]] = v[0]; k}
      end
    end
  end
end
