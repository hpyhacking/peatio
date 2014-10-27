module Deposits
  module CtrlCoinable
    extend ActiveSupport::Concern

    def new
      account = current_user.get_account(channel.currency)
      @address = account.payment_address
      @address.gen_address if @address.address.blank?
      @model = model_kls
      @assets = model_kls.where(member: current_user).order('id desc').first(10)
    end

    def gen_address
      account = current_user.get_account(channel.currency)
      unless account.payment_address.transactions.empty?
        @address = account.payment_addresses.create currency: account.currency
        @address.gen_address if @address.address.blank?
      end

      respond_to do |format|
        format.js do
          render 'private/deposits/shared/gen_address'
        end
      end
    end

  end
end
