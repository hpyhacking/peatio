module Deposits
  module CtrlCoinable
    extend ActiveSupport::Concern

    included do
      skip_filter :auth_member!, only: :create
      skip_filter :auth_verified!, only: :create
      skip_filter :auth_activated!, only: :create
      before_filter :fetch_transaction_raw!, only: :create
    end

    def new
      account = current_user.get_account(channel.currency)
      @address = account.payment_address
      @address.gen_address if @address.address.blank?
      @model = model_kls
      @assets = model_kls.where(member: current_user).order('id desc').first(10)
    end

    def create
      ActiveRecord::Base.transaction do
        unless PaymentTransaction.find_by_txid(@txid)
          tx = PaymentTransaction.create! \
            txid: @txid,
            address: @detail[:address],
            amount: @detail[:amount].to_s.to_d,
            confirmations: @raw[:confirmations],
            receive_at: Time.at(@raw[:timereceived]).to_datetime,
            currency: channel.currency

          deposit = model_kls.create! \
            txid: tx.txid,
            amount: tx.amount,
            member: tx.member,
            account: tx.account,
            currency: tx.currency,
            memo: tx.confirmations

          deposit.submit!
        end
      end

      render nothing: true
    end

    def fetch_transaction_raw!
      puts channel
      raise unless channel.currency_obj.coin?
      sleep 0.5 # nothing result without sleep by query gettransaction api

      @raw = channel.currency_obj.api.gettransaction(params[:txid])
      @txid = @raw[:txid]
      @detail = @raw[:details].first.symbolize_keys!

      if @detail[:account] != "payment" || @detail[:category] != "receive"
        render nothing: true
      end
    end
  end
end
