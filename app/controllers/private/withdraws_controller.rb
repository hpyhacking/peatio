module Private
  class WithdrawsController < BaseController
    def new
      currency = params[:currency] || 'btc'
      @account = current_user.get_account(currency)
      @withdraw = Withdraw.new currency: currency, account: @account
      @withdraw_addresses = current_user.withdraw_addresses.with_category(currency)
      load_history(currency)
    end

    def create
      @withdraw = Withdraw.new(withdraw_params)

      if @withdraw.save
        redirect_to edit_withdraw_path(@withdraw)
      else
        @withdraw_addresses = current_user.withdraw_addresses
        load_history(currency)
        render :new
      end
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.submit!
      redirect_to new_withdraw_path(currency: @withdraw.currency), flash: {notice: t('.request_accepted')}
    end

    def destroy
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.cancel!
      redirect_to new_withdraw_path(currency: @withdraw.currency)
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    private
    def load_history(currency)
      page = params[:page] || 0
      per = params[:per] || 2

      @withdraws_grid = PrivateWithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.with_currency(currency).where(member: current_user).page(page).per(per)
      end
    end

    def withdraw_params
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:sum, :password, :member_id, :account_id, :withdraw_address_id,
                                       :address, :address_label, :address_type, :currency, :save_address)
    end
  end
end
