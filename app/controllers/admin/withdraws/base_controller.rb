require_dependency 'admin/base_controller'

module Admin
  module Withdraws
    class BaseController < BaseController

    protected

      def currency
        Currency.where(type: self.class.name.demodulize.underscore.gsub(/_controller\z/, '').singularize)
                .find_by_code!(params[:currency])
      end

      def find_withdraw
        model     = "::Withdraws::#{self.class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
        @withdraw = model.where(currency: currency).find(params[:id])
      end
    end
  end
end
