module Admin
  module Deposits
    class BitcoinCashController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::BitcoinCash'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24 * 365)
        @bitcoin_cash = @bitcoin_cash.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC').page(params[:page]).per(20)
      end

      def update
        @bitcoin_cash.accept! if @bitcoin_cash.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
