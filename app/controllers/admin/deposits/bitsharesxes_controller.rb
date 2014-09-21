module Admin
  module Deposits
    class BitsharesxesController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Bitsharesx'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @bitsharesxes = @bitsharesxes.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
        @pending_payments = PaymentTransaction::Btsx.where('aasm_state != ?', 'confirmed').order('id DESC')
      end

      def update
        @bitsharesx.accept! if @bitsharesx.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
