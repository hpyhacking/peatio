module Withdraws
  module Withdrawable
    extend ActiveSupport::Concern

    included do
      before_filter :fetch
    end

    def new
      @withdraw = model_kls.new currency: channel.currency, account: @account, member: current_user
    end

    def create
      @withdraw = model_kls.new(withdraw_params)

      if two_factor_auth_verified?
        if @withdraw.save
          @withdraw.submit!
          render nothing: true
        else
          render text: @withdraw.errors.full_messages.join, status: 403
        end
      else
        render text: I18n.t('verify.two_factors.create.error'), status: 403
      end
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])

      if not two_factor_auth_verified?
        render text: @withdraw.errors.full_messages.join, status: 403
      end

      @withdraw.submit!
      render nothing: true
    end

    def destroy
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.cancel!
      render nothing: true
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

  end
end
