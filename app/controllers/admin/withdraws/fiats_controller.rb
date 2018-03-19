require_dependency 'admin/withdraws/base_controller'

module Admin
  module Withdraws
    class FiatsController < BaseController
      before_action :find_withdraw, only: [:show, :update, :destroy]

      def index
        @latest_withdraws  = ::Withdraws::Fiat.where(currency: currency)
                                              .where('created_at <= ?', 1.day.ago)
                                              .order(id: :desc)
        @all_withdraws     = ::Withdraws::Fiat.where(currency: currency)
                                              .where('created_at > ?', 1.day.ago)
                                              .order(id: :desc)
      end

      def show

      end

      def update
        if @withdraw.may_accept?
          @withdraw.accept!
        elsif @withdraw.may_process?
          @withdraw.process!
        elsif @withdraw.may_succeed?
          @withdraw.succeed!
        end
        redirect_to :back, notice: 'Withdraw successfully updated!'
      end

      def destroy
        @withdraw.reject!
        redirect_to :back, notice: 'Withdraw successfully destroyed!'
      end
    end
  end
end
