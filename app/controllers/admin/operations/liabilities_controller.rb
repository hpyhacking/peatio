# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/operations/base_controller'

module Admin
  module Operations
    class LiabilitiesController < BaseController
      def index
        @liabilities = ::Operations::Liability.includes(:reference, :currency)
        @liabilities = @liabilities.where(currency: currency) if currency
        @liabilities = @liabilities.order(id: :desc)
                                   .page(params[:page])
                                   .per(20)
      end
    end
  end
end
