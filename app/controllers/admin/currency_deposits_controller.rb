module Admin
  class CurrencyDepositsController < BaseController
    skip_load_and_authorize_resource

    before_filter :check_member_id
    before_filter :check_auth

    def new
      @deposit = Deposit.new(currency_params)
    end

    def create
      ActiveRecord::Base.transaction do
        @deposit = Deposit.new(currency_params)

        if @deposit.save
          account = @deposit.account
          account.plus_funds @deposit.amount, reason: Account::DEPOSIT, ref: @deposit
          redirect_to admin_member_path(@member), notice: t('.success')
        else
          render :new
        end
      end
    end

    private
    def check_auth
      authorize! :create, Deposit
    end

    def check_member_id
      @member = Member.find_by_sn params[:deposit][:sn]
      @member or return

      account = @member.get_account(:cny)
      params[:deposit][:member_id] = @member.id
      params[:deposit][:account_id] = account.id
      params[:deposit][:currency] = account.currency
    end

    def currency_params
      params[:deposit] ||= {}
      params[:deposit][:state] = :done
      params[:deposit][:done_at] = DateTime.now
      params.require(:deposit).permit(:fund_uid, :fund_extra, :txid, :amount, :member_id, :account_id, :state, :currency, :done_at, :sn)
    end
  end
end
