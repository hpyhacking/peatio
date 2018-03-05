module Deposits
  module CtrlCoinable
    extend ActiveSupport::Concern

    def gen_address
      current_user.get_account(channel.currency).tap do |account|
        next unless account.payment_address.address.blank?
        account.payment_address.enqueue_address_generation
      end
      render nothing: true
    end
  end
end
