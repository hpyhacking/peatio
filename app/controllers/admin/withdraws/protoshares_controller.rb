module Admin
  module Withdraws
    class ProtosharesController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Protoshare'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_protoshares = @protoshares.with_aasm_state(:accepted).order("id DESC")
        @all_protoshares = @protoshares.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @protoshare.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @protoshare.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
