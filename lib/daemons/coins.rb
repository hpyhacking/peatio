# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Currency.coins.order(id: :asc).each do |currency|
    break unless running
    Rails.logger.info { "Processing #{currency.code.upcase} deposits." }
    client    = currency.api
    processed = 0
    options   = client.is_a?(CoinAPI::ETH) ? { transactions_limit: 100 } : { }
    client.each_deposit options do |deposit|
      break unless running
      received_at = deposit[:received_at]
      Rails.logger.debug { "Processing deposit received at #{received_at.to_s('%Y-%m-%d %H:%M %Z')}." } if received_at
      Services::BlockchainTransactionHandler.new(currency).call(deposit)
      processed += 1
      Rails.logger.info { "Processed #{processed} #{currency.code.upcase} #{'deposit'.pluralize(processed)}." }
      break if processed >= 100 || (received_at && received_at <= 1.hour.ago)
    end
    Rails.logger.info { "Finished processing #{currency.code.upcase} deposits." }
  rescue => e
    report_exception(e)
  end
  Kernel.sleep 5
end
