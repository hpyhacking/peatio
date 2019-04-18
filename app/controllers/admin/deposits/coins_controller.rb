# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/deposits/base_controller'

module Admin
  module Deposits
    class CoinsController < BaseController
      def index
        case params.fetch(:state, 'all')
        when 'all'
          @all_deposits = all_deposits.includes(:blockchain)
        when 'latest'
          @latest_deposits = latest_deposits.includes(:blockchain)
        when 'uncollected'
          @uncollected_deposits = uncollected_deposits.includes(:blockchain)
        end
      end

      def update
        deposit = ::Deposits::Coin.where(currency: currency).find(params[:id])
        case params.fetch(:event)
        when 'accept'
          deposit.accept! if deposit.may_accept?
        when 'collect'
          deposit.collect!(false) if deposit.may_dispatch?
        when 'collect_fee'
          deposit.collect!
        end
        redirect_to admin_deposit_index_path(currency.id), notice: 'Deposit succesfully updated.'
      end

      private

      def uncollected_deposits
        all_deposits.where(aasm_state: 'skipped')
      end
    end
  end
end
