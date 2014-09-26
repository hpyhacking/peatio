module Private
  class FundsController < BaseController
    layout 'app'

    before_action :auth_activated!
    before_action :auth_verified!
    before_action :gen_address, only: [:index]

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = Currency.all
      @deposits = current_user.deposits
      @accounts = current_user.accounts
      @withdraws = current_user.withdraws
      @fund_sources = current_user.fund_sources
    end

    private

    def gen_address
      current_user.accounts.each do |account|
        account.payment_addresses.create(currency: account.currency) if account.payment_addresses.blank?
      end
    end
  end
end

