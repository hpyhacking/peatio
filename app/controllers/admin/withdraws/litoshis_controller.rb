module Admin
  module Withdraws
    class LitoshisController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Litoshi'

      def index
        @one_litoshis = @litoshis.with_aasm_state(:accepted).
                           order('id DESC')

        @all_litoshis = @litoshis.without_aasm_state(:accepted).
                           where('created_at > ?', DateTime.now.ago(60 * 60 * 24)).
                           order('id DESC')
      end

      def show
      end

      def update
        @litoshi.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @litoshi.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
