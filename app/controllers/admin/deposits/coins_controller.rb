# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/deposits/base_controller'

module Admin
  module Deposits
    class CoinsController < BaseController
      def index
        case params.fetch(:state, 'all')
        when 'all'
          all_deposits
        when 'latest'
          latest_deposits
        when 'uncollected'
          uncollected_deposits
        end
      end

      def update
        deposit = ::Deposits::Coin.where(currency: currency).find(params[:id])
        case params.fetch(:event)
        when 'accept'
          deposit.accept! if deposit.may_accept?
        when 'collect'
          deposit.collect! if deposit.may_dispatch?
        end
        redirect_to :back, notice: t('admin.deposits.coins.update.notice')
      end

      private

      def all_deposits
        @all_deposits = ::Deposits::Coin.where(currency: currency)
                                        .includes(:member, :currency, :blockchain)
                                        .order(id: :desc)
                                        .page(params[:page])
                                        .per(20)
      end

      def latest_deposits
        @latest_deposits = ::Deposits::Coin.where(currency: currency)
                                            .includes(:member, :currency, :blockchain)
                                            .where('created_at > ?', 1.day.ago)
                                            .order(id: :desc)
                                            .page(params[:page])
                                            .per(20)
      end

      def uncollected_deposits
        @uncollected_deposits = ::Deposits::Coin.where(currency: currency, aasm_state: 'skipped')
                                              .order(id: :desc)
                                              .includes(:member, :currency, :blockchain)
                                              .page(params[:page])
                                              .per(20)
      end
    end
  end
end
