require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

def process_deposits(coin, channel, deposit)
  # Skip if transaction is processed.
  return if PaymentTransaction::Normal.where(txid: deposit[:id]).exists?

  # Skip zombie transactions (for which addresses don't exist).
  recipients = deposit[:entries].map { |entry| entry[:address] }
  return unless recipients.all? { |address| PaymentAddress.where(currency: coin.code, address: address).exists? }

  Rails.logger.info "Missed #{coin.code.upcase} transaction: #{deposit[:id]}."

  # Immediately enqueue job.
  AMQPQueue.enqueue :deposit_coin, { txid: deposit[:id], channel_key: channel.key }
rescue => e
  report_exception(e)
end

while running
  channels = DepositChannel.all.each_with_object({}) { |ch, memo| memo[ch.currency] = ch }
  coins    = Currency.where(coin: true)

  coins.each do |coin|
    next unless (channel = channels[coin.code])

    twelve_hours_ago = 12.hours.ago
    CoinAPI[coin.code.to_sym].each_deposit do |deposit|
      break unless running
      break if deposit[:received_at] < twelve_hours_ago
      process_deposits(coin, channel, deposit)
    end
  end

  Kernel.sleep 5
end
