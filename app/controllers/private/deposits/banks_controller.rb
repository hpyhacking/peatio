module Private
  module Deposits
    class BanksController < ::Private::Deposits::BaseController
      def new
        @deposit = model_kls.new
        @fund_sources = current_user.fund_sources.with_channel(@channel.id)
        gon.banks = Bank.all.reduce({}){|memo, bank| memo[bank.code] = bank.name; memo}
        load_history
      end

      def create
        @deposit = model_kls.new(deposit_params)

        if @deposit.save
          redirect_to url_for(@deposit), notice: t('.success')
        else
          redirect_to({ action: 'new' } , notice: @deposit.errors.full_messages.join('<br>').html_safe)
        end
      end

      def edit
        @deposit = current_user.deposits.find(params[:id]).becomes(model_kls)
        load_history
        unless @deposit.may_submit?
          redirect_to action: 'show'
        end
      end

      def show
        @deposit = current_user.deposits.find(params[:id]).becomes(model_kls)
        load_history
        if @deposit.may_submit?
          redirect_to action: 'edit'
        end
      end

      private
      def load_history
        @bank_deposits_grid = BankDepositsGrid.new(params[:bank_deposits_grid]) do |scope|
          scope.with_currency(@channel.currency).where(member: current_user)
        end

        @assets = @bank_deposits_grid.assets.page(params[:page]).per(10)
      end
      def deposit_params
        params[model_kls.params_name][:member_id] = current_user.id
        params[model_kls.params_name][:currency] = @channel.currency
        params[model_kls.params_name][:account_id] = current_user.get_account(@channel.currency).id
        params.require(model_kls.params_name).permit(:fund_uid, :fund_extra, :amount, :currency, :account_id, :member_id)
      end
    end
  end
end
