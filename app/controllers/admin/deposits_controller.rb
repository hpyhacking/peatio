module Admin
  class DepositsController < BaseController
    def index
      @admin_deposits_grid = Admin::DepositsGrid.new \
        params[:admin_deposits_grid]
      @assets = @admin_deposits_grid.assets.page(params[:page]).per(10)
    end

    def edit
      @deposit = Deposit.find(params[:id])
    end

    def update
      # accpet
      @deposit = Deposit.find(params[:id])

      ActiveRecord::Base.transaction do
        if @deposit.accept! or @deposit.submit!
          redirect_to edit_admin_deposit_path(@deposit), notice: t('.notice')
        else
          redirect_to edit_admin_deposit_path(@deposit), alert: t('.alert')
        end
      end
    end

    def destroy
      # reject
      @deposit = Deposit.find(params[:id])

      ActiveRecord::Base.transaction do
        if @deposit.reject!
          redirect_to admin_deposits_path, notice: t('.notice')
        else
          redirect_to edit_admin_deposit_path(@deposit), alert: t('.alert')
        end
      end
    end
  end
end

