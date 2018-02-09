require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

Rails.logger = @logger = Logger.new STDOUT


$running = true
Signal.trap("TERM") do
  $running = false
end

workers = []
Currency.all.each do |currency|
  workers << Worker::FundStats.new(currency)
  workers << Worker::WalletStats.new(currency)
end
Market.all.each do |market|
  workers << Worker::TradeStats.new(market)
  workers << Worker::TopStats.new(market)
end

while($running) do
  workers.each do |worker|
    begin
      worker.run
    rescue
      Rails.logger.error "#{worker.class.name} failed to run: #{$!}"
      Rails.logger.error $!.backtrace[0,20].join("\n")
    end
  end

  sleep 30
end
