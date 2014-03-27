class PaymentTransactionController < ApplicationController
  before_filter :fetch_transaction_raw

  def create
    unless @txid
      return render nothing: true
    end

    payment_transaction = PaymentTransaction.find_or_initialize_by(txid: @txid)

    if payment_transaction.new_record?
      payment_transaction.assign_attributes \
        state: :unconfirm,
        amount: @detail[:amount].to_s.to_d,
        address: @detail[:address],
        confirmations: @raw[:confirmations],
        receive_at: Time.at(@raw[:timereceived]).to_datetime,
        currency: @currency
      payment_transaction.save
    end

    render nothing: true
  end

  private
  def fetch_transaction_raw
    sleep 1
    @currency = params[:currency]
    raw = CoinRPC[@currency].gettransaction(params[:txid])
    detail = raw[:details].first.symbolize_keys!
    if detail[:account] == "payment" and detail[:category] == "receive"
      @raw = raw
      @detail = detail
      @txid = @raw[:txid]
    end
  end
end
