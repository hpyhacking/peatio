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
        flash.now[:notice] = t('.notice') if @bank.aasm_state.accepted?
      end

      def create
        @bank = ::Deposits::Bank.new(deposit_params)
        if @bank.save
          redirect_to action: :index
        else
          flash[:alert] = @bank.errors.full_messages.first
          render :new
        end
      end

      def update
        if target_params[:txid].blank?
          flash[:alert] = t('.blank_txid')
          redirect_to :back and return
        end

        @bank.charge!(target_params[:txid])

        redirect_to :back
      end

      private
      def target_params
        params.require(:deposits_bank).permit(:txid)
      end

      def deposit_params
        params.require(:deposits_bank).permit(:sn, :amount, :fund_uid, :fund_extra, :currency)
      end
    end
  end
end

