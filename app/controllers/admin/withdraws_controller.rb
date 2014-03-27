module Admin
  class WithdrawsController < BaseController
    def index
      page = params[:page] || 0
      per = params[:per] || 10

      @withdraws_grid = ::WithdrawsGrid.new(params[:withdraws_grid]) do |scope|
        scope.page(page).per(per)
      end
      @assets = @withdraws_grid.assets
    end

    def edit
      @state = @withdraw.state
    end

    def update
      if @withdraw.accepted?
        @withdraw.process!
      elsif @withdraw.processing? and @withdraw.fiat?
        @withdraw.succeed!
      end
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

