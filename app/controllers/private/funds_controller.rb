# encoding: UTF-8
# frozen_string_literal: true

module Private
  class FundsController < BaseController
    include CurrencyHelper

    layout 'funds'

    before_action :trading_must_be_permitted!

    def index
      @currencies        = Currency.enabled.sort
      @deposits          = current_user.deposits.includes(:currency)
      @accounts          = current_user.accounts.enabled.includes(:currency)
      @withdraws         = current_user.withdraws

      gon.jbuilder
    end

    helper_method :currency_icon_url

    def gen_address
      current_user.accounts.enabled.each(&:payment_address)
      render nothing: true
    end
  end
end

