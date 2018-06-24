module Admin
  module Withdraws
    class BonpekaosController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Bonpekao'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_bonpekaos = @bonpekaos.with_aasm_state(:accepted).order("id DESC")
        @all_bonpekaos = @bonpekaos.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @bonpekao.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @bonpekao.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
