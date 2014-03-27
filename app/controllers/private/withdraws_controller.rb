module Private
  class WithdrawsController < BaseController
    def index
      @channels = WithdrawChannel.all
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
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

    private
    def load_history(currency)
      page = params[:page] || 0
      per = params[:per] || 10

      @withdraws_grid = PrivateWithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.with_currency(currency).where(member: current_user).page(page).per(per)
      end
    end

    def withdraw_params
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:sum, :password, :member_id, :account_id, :fund_source_id,
                                       :address, :address_label, :address_type, :currency, :save_address)
    end
  end
end
