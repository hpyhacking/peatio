module Admin
  module Deposits
    class DogecoinsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Dogecoin'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @dogecoins = @dogecoins.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
      end

      def update
        @dogecoin.accept! if @dogecoin.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
