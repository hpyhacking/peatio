module Admin
  module Withdraws
    class BitsharesxesController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Bitsharesx'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_bitsharesxes = @bitsharesxes.with_aasm_state(:accepted).order("id DESC")
        @all_bitsharesxes = @bitsharesxes.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @bitsharesx.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @bitsharesx.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
