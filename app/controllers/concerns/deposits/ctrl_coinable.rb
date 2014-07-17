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

  end
end
