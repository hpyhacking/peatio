module Withdraws
  module CtrlCoinable
    extend ActiveSupport::Concern

    included do
      before_filter :fetch
    end

    def new
      @withdraw ||= model_kls.new currency: channel.currency, \
        account: @account, member: current_user

      @fund_sources = current_user.fund_sources.with_channel(channel.id)
      @assets = model_kls.without_aasm_state(:submitting).where(member: current_user).order('id desc').first(10)
    end

    def create
      @withdraw = model_kls.new(withdraw_params)

      if @withdraw.save
        redirect_to url_for([:edit, @withdraw])
      else
        new
        render :new, alert: t('.alert')
      end
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.submit!
      redirect_to url_for(action: :new), notice: t('.notice')
    end

    def destroy
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.cancel!
      redirect_to url_for(action: :new), notice: t('.notice')
    end

    private

    def fetch
      @account = current_user.get_account(channel.currency)
      @model = model_kls
    end

    def withdraw_params
      params[:withdraw][:currency] = channel.currency
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:member_id, :currency, :sum, :type,
                                       :fund_uid, :fund_extra, :save_fund_source)
    end
  end
end
