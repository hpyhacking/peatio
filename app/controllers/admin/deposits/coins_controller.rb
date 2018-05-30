# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/deposits/base_controller'

module Admin
  module Deposits
    class CoinsController < BaseController
      def index
        @deposits = ::Deposits::Coin.where(currency: currency)
                                    .includes(:member)
                                    .includes(:currency)
                                    .where('created_at > ?', 1.year.ago)
                                    .order(id: :desc)
                                    .page(params[:page])
                                    .per(20)
      end

      def update
        deposit = ::Deposits::Coin.where(currency: currency).find(params[:id])
        deposit.accept! if deposit.may_accept?
        redirect_to :back, notice: t('admin.deposits.coins.update.notice')
      end
    end
  end
end
