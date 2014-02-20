module Private
  class WithdrawsController < BaseController
    def new
      @withdraw = Withdraw.new
      @withdraw_addresses = current_user.withdraw_addresses
      load_history
    end

    def create
      @withdraw = Withdraw.new(withdraw_params)
      withdrawing = Withdrawing.new(@withdraw)

      if withdrawing.request
        redirect_to edit_withdraw_path(@withdraw)
      else
        @withdraw_addresses = current_user.withdraw_addresses
        load_history
        render :new
      end
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.update_attribute(:state, :wait) if @withdraw.state.apply?
      @withdraw.examine
      redirect_to new_withdraw_path, flash: {notice: t('.request_accepted')}
    end

    def destroy
      @withdraw = current_user.withdraws.find(params[:id])
      withdrawing = Withdrawing.new(@withdraw)
      withdrawing.cancel
      redirect_to new_withdraw_path
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    private
    def load_history
      @withdraws_grid = WithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.where(:member_id => current_user.id).first(10)
      end
    end

    def withdraw_params
      params[:withdraw][:state] = :apply
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:sum, :password, :member_id, :withdraw_address_id, :state)
    end
  end
end
