module Deposits
  module CtrlBankable
    extend ActiveSupport::Concern

    included do
      before_filter :fetch
    end

    def new
      @deposit = model_kls.new member: current_user, account: @account, member: current_user
      @fund_sources = current_user.fund_sources.with_channel(@channel.id)
      @assets = model_kls.where(member: current_user).order('id desc').first(10)
      gon.banks = ::Bank.fetch
    end

    def create
      @deposit = model_kls.new(deposit_params)

      if @deposit.save
        redirect_to url_for([:edit, @deposit]), notice: t('.notice')
      else
        new
        render :new
      end
    end

    def edit
      @deposit = current_user.deposits.find(params[:id])
      @assets = model_kls.where(member: current_user).order('id desc').first(10)
    end

    def destroy
      @deposit = current_user.deposits.find(params[:id])
      @deposit.cancel!
      redirect_to url_for(action: :new), notice: t('.notice')
    end

    private

    def fetch
      @account = current_user.get_account(channel.currency)
      @model = model_kls
    end

    def deposit_params
      params[:deposit][:currency] = channel.currency
      params[:deposit][:member_id] = current_user.id
      params[:deposit][:account_id] = @account.id
      params[:deposit][:save_fund_source] = true
      params.require(:deposit).permit(:fund_uid, :fund_extra, :amount, :currency,
                                        :save_fund_source, :account_id, :member_id)
    end
  end
end
