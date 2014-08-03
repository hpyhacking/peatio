module Withdraws
  module CtrlBankable
    extend ActiveSupport::Concern

    included do
      before_filter :fetch
    end

    def new
      @withdraw = model_kls.new currency: channel.currency, account: @account, member: current_user
    end

    def create
      @withdraw = model_kls.new(withdraw_params)

      if @withdraw.save
        redirect_to url_for([:edit, @withdraw]), notice: t('.notice')
      else
        render :new, alert: t('.alert')
      end
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])

      if not two_factor_auth_verified?
        redirect_to url_for(action: :edit), alert: t('.alert_two_factor') and return
      end

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
      @fund_sources = current_user.fund_sources.with_currency(channel.currency)
      @assets = model_kls.without_aasm_state(:submitting).where(member: current_user).order(:id).reverse_order.limit(10)
    end

    def withdraw_params
      params[:withdraw][:currency] = channel.currency
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:fund_source, :member_id, :currency, :sum)
    end

    def two_factor_auth_verified?
      return true if not current_user.two_factors.activated?

      two_factor = current_user.two_factors.by_type(params[:two_factor][:type])
      return false if not two_factor

      two_factor.assign_attributes params.require(:two_factor).permit(:otp)
      two_factor.verify
    end
  end
end
