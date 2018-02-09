require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap(:TERM) { $running = false }

def process(currency)
  if currency.coin?
    Rails.logger.info "Processing #{currency.code.upcase}."
    currency.refresh_balance
    Rails.logger.info 'OK'
  end
rescue CoinAPI::Error => e
  # Currency#refresh_balance may fail with Error.
  # We are silencing these errors to prevent script from
  # always failing processing the same currency and leaving all the rest unprocessed.
  report_exception(e)
end

Currency.all.tap do |currencies|
  while $running do
    currencies.each { |currency| process(currency) }
    Kernel.sleep 5
  end
end
