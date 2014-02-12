module Private
  class PaymentAddressesController < BaseController
    def update
      account = current_user.get_account(params[:currency])
      payment_address = account.payment_addresses.using
      unless payment_address.transactions.empty?
        account.gen_payment_address
      end
      redirect_to funds_path
    end
  end
end

