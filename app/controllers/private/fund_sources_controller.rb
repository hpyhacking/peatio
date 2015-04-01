module Private
  class FundSourcesController < BaseController

    layout false
    before_action :set_variables

    def create
      @fund_source = current_user.fund_sources.new fund_source_params

      if @fund_source.save
        render json: current_user.fund_sources, status: :ok
      else
        head :bad_request
      end
    end

    def destroy
      current_user.fund_sources.find(params[:id]).destroy
      render json: current_user.fund_sources, status: :ok
    end

    private

    def set_variables
      @currency ||= Currency.find_by_code(params[:currency])

      if not @currency.coin?
        @banks ||= Bank.with_currency(params[:currency])
      end
    end

    def fund_source_params
      params[:fund_source][:currency] = params[:currency]
      params.require(:fund_source).permit(:extra, :uid, :currency)
    end
  end
end
