require_dependency 'admin/base_controller'

module Admin
  module Deposits
    class BaseController < BaseController

    protected

      def currency
        Currency.where(type: self.class.name.demodulize.underscore.gsub(/_controller\z/, '').singularize)
                .find_by_code!(params[:currency])
      end
      helper_method :currency
    end
  end
end
