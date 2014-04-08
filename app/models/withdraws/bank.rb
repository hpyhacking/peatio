module Withdraws
  class Bank < ::Withdraw
    enumerize :fund_extra, in: channel.banks, scope: true, \
      i18n_scope: ["withdraw_channel.#{name.demodulize.underscore}.banks", 'banks']

    validates_presence_of :fund_extra

    alias_attribute :remark, :id
  end
end
