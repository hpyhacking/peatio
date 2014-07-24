module Withdraws
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :fund_extra

      delegate :name, to: :member, prefix: true

      alias_attribute :remark, :id

      enumerize :fund_extra, in: channel.banks, scope: true, i18n_scope: 'banks'
    end

    module ClassMethods
      def bank_hash
        enumerized_attributes['fund_extra'].options.inject({}) {|k, v| k[v[1]] = v[0]; k}
      end
    end
  end
end
