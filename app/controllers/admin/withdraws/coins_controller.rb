# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/withdraws/base_controller'

module Admin
  module Withdraws
    class CoinsController < BaseController
      before_action :find_withdraw, only: [:show, :update, :destroy]

      def index
        case params.fetch(:state, 'all')
        when 'all'
          all_withdraws
        when 'latest'
          latest_withdraws
        when 'pending'
          pending_withdraws
        end
      end

      def show

      end

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
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end

      private

      def all_withdraws
        @all_withdraws     = ::Withdraws::Coin.where(currency: currency)
                                              .order(id: :desc)
                                              .includes(:member, :currency, :blockchain)
      end

      def latest_withdraws
        @latest_withdraws  = ::Withdraws::Coin.where(currency: currency)
                                              .where('created_at > ?', 1.day.ago)
                                              .order(id: :desc)
                                              .includes(:member, :currency, :blockchain)
      end

      def pending_withdraws
        @pending_withdraws = ::Withdraws::Coin.where(currency: currency, aasm_state: 'accepted')
                                              .where('created_at  < ?', 1.minute.ago)
                                              .order(id: :desc)
                                              .includes(:member, :currency, :blockchain)
      end

      def process!
        @withdraw.transaction do
          @withdraw.accept!
          @withdraw.process!
        end
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end

      def load!
        @withdraw.transaction do
          @withdraw.update!(txid: params.fetch(:txid))
          @withdraw.load!
        end
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end
    end
  end
end
