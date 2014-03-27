module Private::Withdraws
  class BankController < ::Private::WithdrawsController
    def new
      @channel = WithdrawChannel.get('bank')
      @account = current_user.get_account(@channel.currency)
      @withdraw = Withdraw.new currency: @channel.currency, account: @account
      @fund_sources = current_user.fund_sources.with_currency(@channel.currency)
      load_history(@channel.currency)
    end
  end
end
