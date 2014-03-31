module Private
  class DepositsController < BaseController
    def index
      @depostis = DepositChannel.all
    end

    def update
      @deposit = current_user.deposits.find(params[:id])
      if @deposit.submit!
        redirect_to :back, notice: t('.notice')
      else
        redirect_to :back, alert: t('.alert')
      end
    end

    def destroy
      @deposit = current_user.deposits.find(params[:id])
      if @deposit.cancel!
        redirect_to :back, notice: t('.notice')
      else
        1/0
        redirect_to :back, alert: t('.alert')
      end
    end
  end
end
