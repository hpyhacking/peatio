require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

def load_transactions(coin)
  # Download more transactions which is safer in case daemon haven't been active long time.
  # NOTE: The second argument of CoinRPC#listtransactions has different meaning for XRP. Check the sources.
  CoinRPC[coin.code.to_sym].listtransactions('payment', coin.code.xrp? ? 100 : 1000)
rescue => e
  Kernel.print e.inspect, "\n", e.backtrace.join("\n"), "\n\n"
  [] # Fallback with empty transaction list.
end

def process_transaction(coin, channel, tx)
  return if tx['category'] != 'receive'

  # Skip if transaction exists.
  return if PaymentTransaction::Normal.where(txid: tx['txid']).exists?

  # Skip zombie transactions (for which addresses don't exist).
  return unless PaymentAddress.where(currency: coin.code, address: tx['address']).exists?

  Kernel.puts "Missed #{coin.code.upcase} transaction: #{tx['txid']}."

  # Immediately enqueue job.
  AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], channel_key: channel.key }
rescue => e
  Kernel.print e.inspect, "\n", e.backtrace.join("\n"), "\n\n"
end

while running
  channels = DepositChannel.all.each_with_object({}) { |ch, memo| memo[ch.currency] = ch }
  coins    = Currency.where(coin: true)

  coins.each do |coin|
    next unless (channel = channels[coin.code])

    load_transactions(coin).each do |tx|
      break unless running
      process_transaction(coin, channel, tx)
    end
  end

  Kernel.sleep 5
end
