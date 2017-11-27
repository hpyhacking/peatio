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
    transactions(code, account, number).each do |tx|
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
        p tx
        AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], channel_key: channel.key }
      end
      puts "Done."
    end
  end
end

def transactions(code, account, number)
  case code
  when :btc
    CoinRPC[code].listtransactions(account, number)
  when :xrp
    txs = []

    PaymentAddress.where(currency: Currency.find_by_code('xrp').id).each do |a|
      txs.concat(CoinRPC[code].listtransactions(a.address))
    end

    txs.map do |tx|
      {
        'address'  => tx['Account'],
        'amount'   => tx['Amount'],
        'category' => 'receive',
        'txid'     => tx['hash'],
        'walletconflicts' => []
      }
    end
  else
    []
  end
end
