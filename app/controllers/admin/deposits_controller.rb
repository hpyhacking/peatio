module Admin
  class DepositsController < BaseController
    def index
      @admin_deposits_grid = Admin::DepositsGrid.new \
        params[:admin_deposits_grid]
      @assets = @admin_deposits_grid.assets.page(params[:page]).per(10)
    end

    def show
      @deposit = Deposit.find(params[:id])
    end

    def update
      @deposit = Deposit.find(params[:id])

      ActiveRecord::Base.transaction do
        if @deposit.update_attributes(destroy_params) \
          && @deposit.accept!
          redirect_to admin_deposits_path, notice: t('.notice')
        else
          redirect_to admin_deposit_path(@deposit), alert: t('.alert')
        end
      end
    end

    def destroy
      @deposit = Deposit.find(params[:id])

      ActiveRecord::Base.transaction do
        if @deposit.update_attributes(destroy_params) \
          && @deposit.reject!
          redirect_to admin_deposits_path, notice: t('.notice')
        else
          redirect_to admin_deposit_path(@deposit), alert: t('.alert')
        end
      end
    end

    def destroy_params
      params.require(:deposit).permit(:memo)
    end
  end
end

