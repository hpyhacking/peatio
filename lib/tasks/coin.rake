namespace :coin do
  desc "Sync coin deposit transactions"
  task sync_deposit: :environment do
    code    = ENV['code']
    account = 'payment'
    number  = ENV['number'] ? ENV['number'].to_i : 100
    channel = DepositChannel.find_by_currency(code)

    if channel.blank?
      puts "Can not find the deposit channel by code: #{code}"
      exit 0
    end

    missed = []
    CoinRPC[code].listtransactions(account, number).each do |tx|
      next if tx['category'] != 'receive'

      unless PaymentTransaction::Normal.where(txid: tx['txid'], address: tx['address']).first
        puts "Missed txid:#{tx['txid']} address:#{tx['address']} (#{tx['amount']})"
        missed << tx
      end
    end
    puts "#{missed.size} missed transactions found."

    if ENV['reprocess'] == '1' && missed.size > 0
      puts "Reprocessing .."
      missed.each do |tx|
        AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], channel_key: channel.key }
      end
      puts "Done."
    end
  end
end
