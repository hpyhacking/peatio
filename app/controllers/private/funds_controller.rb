module Private
  class FundsController < BaseController
    layout 'app'

    before_action :auth_activated!
    before_action :auth_verified!
    before_action :two_factor_activated!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = Currency.all.sort
      @deposits = current_user.deposits
      @accounts = current_user.accounts
      @withdraws = current_user.withdraws
      @fund_sources = current_user.fund_sources
    end

    def gen_address
      current_user.accounts.each do |account|
        account.payment_addresses.create(currency: account.currency) if account.payment_addresses.blank?
      end
      render nothing: true
    end

  end
end

