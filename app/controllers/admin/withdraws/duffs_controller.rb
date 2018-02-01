module Admin
  module Withdraws
    class DuffsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Duff'

      def index
        @one_duffs = @duffs.with_aasm_state(:accepted)
                           .order('id DESC')

        @all_duffs = @duffs.without_aasm_state(:accepted)
                           .where('created_at > ?', 1.day.ago)
                           .order('id DESC')
      end

      def show; end

      def update
        @duff.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @duff.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
