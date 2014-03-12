module Admin
  class WithdrawsController < BaseController
    def index
      @withdraws_grid = ::WithdrawsGrid.new(params[:withdraws_grid])
      @assets = @withdraws_grid.assets
    end

    def edit
      @state = @withdraw.state
    end

    def update
      @withdraw.process!
      flash[:notice] = t('.success')
      redirect_to admin_withdraws_path
    end

    def destroy
      @withdraw.reject!
      flash[:notice] = t('.success')
      redirect_to admin_withdraws_path
    end
  end
end

