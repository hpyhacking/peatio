class WebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action      :auth_anybody!
  before_action      :currency_exists!

  # Used by SAAS Bitcoin wallets like BitGo.
  #
  # The current implementation works so:
  #   * Service triggers webhook when new transaction has been created.
  #   * Webhook validates incoming data and enqueues async processing of transaction.
  def tx_created
    if params[:type] == 'transaction' && params[:hash].present?
      AMQPQueue.enqueue(:deposit_coin, txid: params[:hash], currency: params[:ccy])
      head :no_content
    else
      head :unprocessable_entity
    end
  end

private

  def currency_exists!
    head :unprocessable_entity unless params[:ccy].in?(Currency.coins.map(&:code))
  end
end
