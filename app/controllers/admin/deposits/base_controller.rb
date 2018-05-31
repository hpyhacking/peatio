# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/base_controller'

module Admin
  module Deposits
    class BaseController < BaseController

    protected

      def currency
        Currency.where(type: self.class.name.demodulize.underscore.gsub(/_controller\z/, '').singularize)
                .find(params[:currency])
      end
      helper_method :currency
    end
  end
end
