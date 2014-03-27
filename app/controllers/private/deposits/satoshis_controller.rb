module Private
  module Deposits
    class SatoshisController < BaseController
      skip_filter :auth_member!, only: :create
      skip_filter :auth_activated!, only: :create
      before_filter :fetch_transaction_raw!, only: :create

      def new
        account = current_user.get_account(@currency)
        account.gen_payment_address if account.payment_addresses.empty?
        @address = account.payment_addresses.using

        @coin_deposits_grid = CoinDepositsGrid.new(params[:coin_deposits_grid]) do |scope|
          scope.with_currency(@currency).where(member: current_user)
        end
        @assets = @coin_deposits_grid.assets.page(params[:page]).per(5)
      end

      def create
        tx = PaymentTransaction.find_or_initialize_by(txid: @txid)

        if tx.new_record?
          ActiveRecord::Base.transaction do
            tx.update_attributes! \
              state: :unconfirm,
              amount: @detail[:amount].to_s.to_d,
              address: @detail[:address],
              confirmations: @raw[:confirmations],
              receive_at: Time.at(@raw[:timereceived]).to_datetime,
              currency: @currency,
              channel: @channel
          end
        end

        render nothing: true
      end

      private
      def fetch_transaction_raw!
        sleep 1
        raw = CoinRPC[@currency].gettransaction(params[:txid])
        detail = raw[:details].first.symbolize_keys!
        if detail[:account] == "payment" and detail[:category] == "receive"
          @raw = raw
          @detail = detail
          @txid = @raw[:txid]
        else
          render nothing: true
        end
      end
    end
  end
end
