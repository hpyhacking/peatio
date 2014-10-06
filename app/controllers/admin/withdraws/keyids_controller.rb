module Admin
  module Withdraws
    class KeyidsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Keyid'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_keyids = @keyids.with_aasm_state(:accepted).order("id DESC")
        @all_keyids = @keyids.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @keyid.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @keyid.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
