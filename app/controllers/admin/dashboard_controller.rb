# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    skip_load_and_authorize_resource

    def index
      @currencies_summary = Currency.all.map(&:summary)
      @register_count = Member.count
    end
  end
end
