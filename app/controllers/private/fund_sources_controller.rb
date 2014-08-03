module Private
  class FundSourcesController < BaseController

    before_action :set_variables

    def index
      @fund_sources = current_user.fund_sources.with_currency(params[:currency])
    end

    def new
      @fund_source = current_user.fund_sources.new
    end

    def create
      @fund_source = current_user.fund_sources.new fund_source_params

      if @fund_source.save
        redirect_to [params[:currency], :fund_sources]
      else
        render :new
      end
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
