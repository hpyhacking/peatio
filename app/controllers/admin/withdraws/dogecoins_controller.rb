module Admin
  module Withdraws
    class DogecoinsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Dogecoin'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_dogecoins = @dogecoins.with_aasm_state(:accepted).order("id DESC")
        @all_dogecoins = @dogecoins.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @dogecoin.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @dogecoin.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
