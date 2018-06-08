# encoding: UTF-8
# frozen_string_literal: true

module Private
  class WithdrawsController < BaseController
    before_action :withdraws_must_be_permitted!

    def create
      @withdraw = withdraw_class.new(withdraw_params)

      if @withdraw.save
        @withdraw.submit!
        head 204
      else
        render text: @withdraw.errors.full_messages.join(', '), status: 422
      end
    end

    def destroy
      Withdraw.transaction do
        @withdraw = current_user.withdraws.find(params[:id]).lock!
        @withdraw.cancel
        @withdraw.save!
      end
      head 204
    end

  private

    def currency
      @currency ||= Currency.enabled.find(params[:currency])
    end

    def withdraw_class
      "withdraws/#{currency.type}".camelize.constantize
    end

    def withdraw_params
      params.require(:withdraw)
            .permit(:rid, :member_id, :currency_id, :sum)
            .merge(currency_id: currency.id, member_id: current_user.id)
            .permit!
    end
  end
end
