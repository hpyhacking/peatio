module Withdraws
  module Withdrawable
    extend ActiveSupport::Concern

    included do
      before_filter :fetch
    end

    def create
      @withdraw = model_kls.new(withdraw_params)

    end

    def destroy
      Withdraw.transaction do
        @withdraw = current_user.withdraws.find(params[:id]).lock!
        @withdraw.cancel
        @withdraw.save!
      end
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
      params.require(:withdraw).permit(:fund_source_id, :member_id, :currency, :sum)
    end

  end
end
