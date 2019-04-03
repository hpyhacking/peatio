# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/base_controller'

module Admin
  module Withdraws
    class BaseController < BaseController

      protected

      def all_withdraws
        ::Withdraw.where(currency: currency)
                  .order(id: :desc)
                  .includes(:member, :currency)
                  .page(params[:page])
                  .per(20)
      end

      def latest_withdraws
        all_withdraws.where('created_at > ?', 1.day.ago)
      end

      def currency
        @currency ||= Currency.find(params[:currency])
      end

      def find_withdraw
        model     = "::Withdraws::#{self.class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
        @withdraw = model.where(currency: currency).find(params[:id])
      end

      helper_method :latest_withdraws, :all_withdraws, :currency, :find_withdraw
    end
  end
end
