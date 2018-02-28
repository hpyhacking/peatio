require_dependency 'admin/withdraws/base_controller'

module Admin
  module Withdraws
    class BanksController < BaseController
      load_and_authorize_resource :class => '::Withdraws::Bank'
      before_action :find_withdraw, only: [:show, :update, :destroy]

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_banks = @banks.with_aasm_state(:accepted, :processing).order("id DESC")
        @all_banks = @banks.without_aasm_state(:accepted, :processing).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        if @bank.may_accept?
          @bank.accept!
        elsif @bank.may_process?
          @bank.process!
        elsif @bank.may_succeed?
          @bank.succeed!
        end
        redirect_to :back, notice: 'Withdraw successfully updated!'
      end

      def destroy
        @bank.reject!
        redirect_to :back, notice: 'Withdraw successfully destroyed!'
      end
    end
  end
end
