module Admin
  class DashboardController < BaseController
    skip_load_and_authorize_resource

    def index
      @daemon_statuses = Global.daemon_statuses
      @currencies_summary = Currency.all.map(&:summary)
    end
  end
end
