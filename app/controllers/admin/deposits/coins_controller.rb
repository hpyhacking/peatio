require_dependency 'admin/deposits/base_controller'

module Admin
  module Deposits
    class CoinsController < BaseController
      def index
        @deposits = deposit_model.includes(:member)
                                 .where('created_at > ?', 1.year.ago)
                                 .order(id: :desc)
                                 .page(params[:page])
                                 .per(20)
      end

      def update
        deposit = deposit_model.find(params[:id])
        deposit.accept! if deposit.may_accept?
        redirect_to :back, notice: t('admin.deposits.coins.update.notice')
      end

    private

      def deposit_model
        "::Deposits::#{self.class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
      end
      helper_method :deposit_model
    end
  end
end
