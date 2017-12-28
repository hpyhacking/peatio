require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap(:TERM) { $running = false }

def process(currency)
  if currency.coin?
    Kernel.print "Processing #{currency.code.upcase}... "
    currency.refresh_balance
    Kernel.print "OK\n\n"
  end
rescue CoinRPC::JSONRPCError => e
  # Currency#refresh_balance may fail with JSONRPCError.
  # We are silencing these errors to prevent script from
  # always failing processing the same currency and leaving all the rest unprocessed.
  Kernel.print e.inspect, "\n\n"
end

Currency.all.tap do |currencies|
  while $running do
    currencies.each { |currency| process(currency) }
    Kernel.sleep 5
  end
end
