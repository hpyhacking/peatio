require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

def process_deposits(coin, channel, deposit)
  # Skip if transaction is fully processed.
  fully_processed = !deposit[:entries].find.with_index do |e, i|
    !PaymentTransaction::Normal.where(txid: deposit[:id], txout: i).exists?
  end
  return if fully_processed

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

    processed = 0
    CoinAPI[coin.code.to_sym].each_deposit do |deposit|
      break unless running
      process_deposits(coin, channel, deposit)
      break if (processed += 1) >= 100
    end
  end

  Kernel.sleep 5
end
