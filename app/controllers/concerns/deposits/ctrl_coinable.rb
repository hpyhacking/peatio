module Deposits
  module CtrlCoinable
    extend ActiveSupport::Concern

    def gen_address
      current_user.get_account(channel.currency).tap do |account|
        if account.payment_addresses.empty?
          account.payment_addresses.create!(currency: account.currency)
        end
      end
      render nothing: true
    end
  end
end
