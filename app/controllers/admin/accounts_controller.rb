module Admin
  class AccountsController < BaseController
    def index
      @member = Member.find(params[:member_id])
      @accounts = @member.accounts
    end

    def edit
      @account = Account.find(params[:id])
    end

    def update
      Account.find(params[:id]).update!(account_params)
      redirect_to admin_member_accounts_path(params[:member_id])
    end

    private
    def account_params
      params.require(:account).permit(:balance, :locked)
    end
  end
end
