module Admin
  module Withdraws
    class BitcoinCashController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::BitcoinCash'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_bitcoin_cash = @bitcoin_cash.with_aasm_state(:accepted).order("id DESC")
        @all_bitcoin_cash = @bitcoin_cash.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @bitcoin_cash.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @bitcoin_cash.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
