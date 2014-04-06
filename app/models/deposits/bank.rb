module Deposits
  class Bank < ::Deposit
    include ::AasmStateI18nable
    attr_accessor :holder, :remember

    delegate :receive_fund_holder_text, :receive_fund_uid_text, :receive_fund_extra_text, to: :channel
    delegate :sn, to: :member, prefix: true

    enumerize :fund_extra, in: channel.banks, scope: true, \
      i18n_scope: ["deposit_channel.#{name.demodulize.underscore}.banks", 'banks']

    validates_presence_of :fund_extra, :fund_uid, :amount
  end
end
