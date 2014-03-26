module Private
  class WithdrawSatoshiChannelsController < BaseController
    def new
      @channel = WithdrawSatoshiChannel.get
      @account = current_user.get_account(@channel.currency)
      @withdraw = Withdraw.new currency: @channel.currency, account: @account
      @fund_sources = current_user.fund_sources.with_currency(@channel.currency)
      load_history(@channel.currency)
    end

    def create
      @withdraw = Withdraw.new(withdraw_params)

      if @withdraw.save
        redirect_to edit_withdraw_path(@withdraw)
      else
        @fund_sources = current_user.fund_sources
        load_history(currency)
        render :new
      end
    end

    private

    def withdraw_params
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:sum, :password, :member_id, :account_id, :fund_source_id,
                                       :address, :address_label, :address_type, :currency, :save_address)
    end

    # use cells ?
    def load_history(currency)
      page = params[:page] || 0
      per = params[:per] || 10

      @withdraws_grid = PrivateWithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.with_currency(currency).where(member: current_user).page(page).per(per)
      end
    end
  end
end

