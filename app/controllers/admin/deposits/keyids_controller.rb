module Admin
  module Deposits
    class KeyidsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Keyid'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @keyids = @keyids.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
        @pending_payments = PaymentTransaction::Dns.with_aasm_state(:unconfirm).order('id DESC')
      end

      def update
        @keyid.accept! if @keyid.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
