module Private
  class DepositsController < BaseController
    before_action :auth_activated!, only: [:coin, :bank]

    def coin
      currency = params[:currency]
      redirect_to root_path unless Currency.coins.keys.include?(currency)

      @account = current_user.get_account(currency)
      @account.gen_payment_address if @account.payment_addresses.empty?
      @address = @account.payment_addresses.using
    end

    def bank
      @deposit = DepositChannel.find('bank')
    end

    def index
      @depostis = DepositChannel.all
      @accounts = current_user.accounts
    end
  end
end
