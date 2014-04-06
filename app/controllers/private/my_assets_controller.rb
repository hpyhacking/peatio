module Private
  class MyAssetsController < BaseController
    def index
      @accounts = current_user.accounts
      load_deposits
      load_withdraws
    end

    private
    def load_deposits
      page = params[:page] || 0
      per = params[:per] || 10

      @deposits_grid = DepositsGrid.new(params[:deposits_grid]) do |scope|
        scope.where(member: current_user).page(page).per(per)
      end
    end

    def load_withdraws
      page = params[:page] || 0
      per = params[:per] || 10

      @withdraws_grid = WithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.where(member: current_user).page(page).per(per)
      end
    end
  end
end
