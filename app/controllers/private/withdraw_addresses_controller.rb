module Private
  class WithdrawAddressesController < BaseController
    def index
      @withdraw_address = WithdrawAddress.new
    end

    def create
      @withdraw_address = WithdrawAddress.new(withdraw_address_params)

      if @withdraw_address.save
        redirect_to new_withdraw_path
      else
        render :index
      end
    end

    def destroy
      WithdrawAddress.where(
        :id => params[:id],
        :is_locked => false,
        :account_id => current_user.accounts).destroy_all
      redirect_to withdraws_path
    end

    private

    def withdraw_address_params
      params[:withdraw_address][:is_locked] = false
      category = params[:withdraw_address][:category]
      if category and !category.empty?
        currency = WithdrawChannel.currency(category)
        account = current_user.get_account(currency)
        params[:withdraw_address][:account_id] = account.id
      end
      params.required(:withdraw_address).permit(:label, :address, :category, :account_id, :is_locked)
    end
  end
end

