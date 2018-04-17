require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

def process_deposits(currency, deposit)
  # Skip if transaction is processed.
  return if Deposits::Coin.where(currency: currency, txid: deposit[:id]).exists?

  # Skip zombie transactions (for which addresses don't exist).
  recipients = deposit[:entries].map { |entry| entry[:address] }
  return unless recipients.all? { |address| PaymentAddress.where(currency: currency, address: address).exists? }

  Rails.logger.info "Missed #{currency.code.upcase} transaction: #{deposit[:id]}."

  # Immediately enqueue job.
  AMQPQueue.enqueue :deposit_coin, { txid: deposit[:id], currency: currency.code }
rescue => e
  report_exception(e)
end

while running
  Currency.coins.each do |currency|
    # TODO: Find a better way for limiting amount of transactions to process (Yaroslav Konoplov).
    processed = 0
    currency.api.each_deposit do |deposit|
      break unless running
      process_deposits(currency, deposit)
      break if (processed += 1) >= 1000
    end
  end

  Kernel.sleep 5
end
