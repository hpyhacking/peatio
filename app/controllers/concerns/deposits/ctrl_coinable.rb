module Deposits
  module CtrlCoinable
    extend ActiveSupport::Concern

    def gen_address
      current_user.get_account(channel.currency).tap do |acc|
        acc.payment_addresses.create!(currency: acc.currency)
        acc.payment_addresses.each { |addr| addr.gen_address if addr.address.blank? }
      end
      render nothing: true
    end
  end
end
