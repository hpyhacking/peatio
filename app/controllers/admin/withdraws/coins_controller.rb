module Admin
  module Withdraws
    class CoinsController < BaseController
      def index
        @accepted_withdraws   = withdraw_model.with_aasm_state(:accepted).order(id: :desc)
        @unaccepted_withdraws = withdraw_model.without_aasm_state(:accepted).where('created_at > ?', 1.day.ago).order(id: :desc)
      end

      def show

      end

      def update
        @withdraw.process!
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end

      def destroy
        @withdraw.reject!
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end

    private

      def withdraw_model
        "::Withdraws::#{self.class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
      end
      helper_method :withdraw_model
    end
  end
end
