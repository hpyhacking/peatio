module Admin
  module Deposits
    class BanksController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Bank'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @oneday_banks = @banks.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
        
        @available_banks = @banks.includes(:member).
          with_aasm_state(:submitting, :warning, :submitted).
          order('id DESC')

        @available_banks -= @oneday_banks
      end

      def show
        if params[:target]
          @target = ::Deposits::Bank.new(target_params)
          @match = @bank.sn == @target.sn &&
            @bank.member.name == @target.holder &&
            @bank.amount == @target.amount
          flash.now[:notice] = t('.notice') if @bank.aasm_state.accepted?
        else
          @match = false
          flash.now[:alert] = t('.alert') if @bank.aasm_state.accepted?
        end
      end

      def update
        raise 'unknown txid' unless params[:txid]

        ActiveRecord::Base.transaction do
          @bank.lock!
          @bank.submit!
          @bank.accept!
          @bank.touch(:done_at)
          @bank.update_attribute(:txid, params[:txid])
        end

        redirect_to :back
      end

      private
      def target_params
        params.require(:target).permit(:sn, :holder, :amount, :created_at, :txid)
      end
    end
  end
end

