module Admin
  module Withdraws
    class BanksController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Bank'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_banks = @banks.with_aasm_state(:accepted, :processing).order("id DESC")
        @all_banks = @banks.without_aasm_state(:accepted, :processing).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        if @bank.may_process?
          @bank.process!
        elsif @bank.may_succeed?
          @bank.succeed!
        end

        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @bank.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
