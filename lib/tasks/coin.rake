namespace :coin do
  desc "Sync coin deposit transactions"
  task sync_deposit: :environment do
    code    = ENV['code'].to_sym
    account = 'payment'
    number  = ENV['number'] ? ENV['number'].to_i : 100
    channel = DepositChannel.find_by_currency(code)

    if channel.blank?
      puts "Can not find the deposit channel by code: #{code}"
      exit 0
    end

    missed = []
    CoinAPI[code].listtransactions(account, number).each do |tx|
      next if tx['category'] != 'receive'

      unless PaymentTransaction::Normal.find_by(txid: tx['txid'])
        puts "#{code} --- Missed txid:#{tx['txid']} address:#{tx['address']} (#{tx['amount']})"
        missed << tx
      end
    end

    puts "#{code} --- #{missed.size} missed transactions found."

    next if missed.empty? || ENV['reprocess'].nil?

    puts "#{code} --- Reprocessing .."
    missed.each do |tx|
      AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], currency: channel.currency.code }
    end
    puts "#{code} --- Done."
  end
end
