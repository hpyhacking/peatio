module Admin
  module Withdraws
    class RipplesController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Ripple'

      def index
        @one_ripples = @ripples.with_aasm_state(:accepted)
                               .order('id DESC')

        @all_ripples = @ripples.without_aasm_state(:accepted)
                               .where('created_at > ?', 1.day.ago)
                               .order('id DESC')
      end

      def show; end

      def update
        @ripple.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @ripple.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
