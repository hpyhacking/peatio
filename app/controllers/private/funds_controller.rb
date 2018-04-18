module Private
  class FundsController < BaseController
    include CurrencyHelper

    layout 'funds'

    before_action :auth_verified!

    def index
      @currencies        = Currency.all.sort
      @deposits          = current_user.deposits
      @accounts          = current_user.accounts.enabled
      @withdraws         = current_user.withdraws

      gon.jbuilder
    end

    helper_method :currency_icon_url

    def gen_address
      current_user.accounts.each do |account|
        account.payment_address&.enqueue_address_generation
      end
      render nothing: true
    end
  end
end

