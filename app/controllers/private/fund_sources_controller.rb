module Private
  class FundSourcesController < BaseController

    before_action :set_currency

    def index

    end

    def new
      @fund_source = current_user.fund_sources.new currency: @currency.code
    end

    private

    def set_currency
      @currency ||= Currency.find_by_code(params[:currency])
    end
  end
end
