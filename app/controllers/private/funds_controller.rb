module Private
  class FundsController < BaseController
    layout 'funds'

    before_action :auth_verified!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = Currency.all.sort
      @deposits = current_user.deposits
      @accounts = current_user.accounts.enabled
      @withdraws = current_user.withdraws
      @fund_sources = current_user.fund_sources

      gon.jbuilder
    end

    def gen_address
      current_user.accounts.each do |account|
        next unless account.currency_obj&.coin?

        if account.payment_addresses.empty?
          account.payment_addresses.create!(currency: account.currency)
        end
      end
      render nothing: true
    end
  end
end

