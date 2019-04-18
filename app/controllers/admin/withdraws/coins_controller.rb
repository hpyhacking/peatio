# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/withdraws/base_controller'

module Admin
  module Withdraws
    class CoinsController < BaseController
      before_action :find_withdraw, only: %i[show update destroy]

      def index
        case params.fetch(:state, 'all')
        when 'all'
          @all_withdraws = all_withdraws.includes(:blockchain)
        when 'latest'
          @latest_withdraws = latest_withdraws.includes(:blockchain)
        when 'pending'
          @pending_withdraws = pending_withdraws.includes(:blockchain)
        end
      end

      def show; end

      def update
        case params.fetch(:event)
        when 'process'
          process!
        when 'load'
          load!
        end
      end

      def destroy
        @withdraw.reject!
        redirect_to admin_withdraw_path(currency.id, @withdraw.id), notice: 'Withdrawal succesfully updated.'
      end

      private

      def pending_withdraws
        all_withdraws.where(aasm_state: 'accepted')
                     .where('created_at  < ?', 1.minute.ago)
      end

      def process!
        @withdraw.transaction do
          @withdraw.accept!
          @withdraw.process!
        end
        redirect_to admin_withdraw_path(currency.id, @withdraw.id), notice: 'Withdrawal succesfully updated.'
      end

      def load!
        @withdraw.transaction do
          @withdraw.update!(txid: params.fetch(:txid))
          @withdraw.load!
        end
        redirect_to admin_withdraw_path(currency.id, @withdraw.id), notice: 'Withdrawal succesfully updated.'
      end
    end
  end
end
