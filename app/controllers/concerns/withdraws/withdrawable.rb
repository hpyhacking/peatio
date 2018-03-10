module Withdraws
  module Withdrawable
    extend ActiveSupport::Concern

    included do
      before_filter :fetch
    end

    def create
      @withdraw = model_kls.new(withdraw_params)

      if @withdraw.save
        @withdraw.submit!
        render nothing: true
      else
        render text: @withdraw.errors.full_messages.join(', '), status: 403
      end
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
      @account                = current_user.get_account(channel.currency)
      @model                  = model_kls
      @withdraw_destinations  = current_user.withdraw_destinations.with_currency(channel.currency)
      @assets                 = model_kls.without_aasm_state(:submitting).where(member: current_user).order(:id).reverse_order.limit(10)
    end

    def withdraw_params
      params[:withdraw][:currency_id] = channel.currency.id
      params[:withdraw][:member_id]   = current_user.id
      params.require(:withdraw).permit(:destination_id, :member_id, :currency_id, :sum)
    end
  end
end
