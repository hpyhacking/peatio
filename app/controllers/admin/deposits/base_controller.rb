# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/base_controller'

module Admin
  module Deposits
    class BaseController < BaseController

      protected

      def all_deposits
        ::Deposit.where(currency: currency)
                 .includes(:member, :currency)
                 .order(id: :desc)
                 .page(params[:page])
                 .per(20)
      end

      def latest_deposits
        all_deposits.where('created_at > ?', 1.day.ago)
      end

      def currency
        @currency ||= Currency.find(params[:currency])
      end

      helper_method :all_deposits, :latest_deposits, :currency
    end
  end
end
