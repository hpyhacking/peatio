module Private
  class WithdrawsController < BaseController
    def index
      @channels = WithdrawChannel.all
    end

    def create
      @withdraw = Withdraw.new(withdraw_params)

      if @withdraw.save
        redirect_to edit_withdraw_path(@withdraw)
      else
        @fund_sources = current_user.fund_sources
        load_history(@withdraw.channel_id)
        render :new
      end
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.submit!
      redirect_to withdraws_path, flash: {notice: t('.request_accepted')}
    end

    def destroy
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.cancel!
      redirect_to withdraws_path
    end

    private
    def load_history(channel_id)
      page = params[:page] || 0
      per = params[:per] || 10

      @withdraws_grid = PrivateWithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.with_channel(channel_id).where(member: current_user).page(page).per(per)
      end
    end

    def withdraw_params
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:password, :member_id, :account_id, :currency, :channel_id,
                                       :sum, :fund_uid, :fund_extra,  :save_fund_source)
    end
  end
end
