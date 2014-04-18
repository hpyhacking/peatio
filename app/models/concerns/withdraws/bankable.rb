module Withdraws
  module Bankable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :fund_extra

      delegate :name, to: :member, prefix: true

      alias_attribute :remark, :id

      enumerize :fund_extra, in: channel.banks, scope: true, \
        i18n_scope: ["withdraw_channel.#{name.demodulize.underscore}.banks", 'banks']

    end
  end
end
