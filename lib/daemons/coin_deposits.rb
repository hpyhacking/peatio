#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  # PaymentTransactionController process unconfirm transaction created
  # Daemon process update state and confirmations to final
  #
  unconfirms = PaymentTransaction.with_state(:unconfirm).load
  unconfirms.each do |payment_transaction|
    ActiveRecord::Base.transaction do
      rpc = CoinRPC[payment_transaction.currency]
      raw = rpc.gettransaction(payment_transaction.txid)

      payment_transaction.lock!
      next unless payment_transaction.check(raw)
      payment_transaction.account.lock!

      payment_transaction.deposit!(raw)
      payment_transaction.confirm!(raw)
    end
  end

  confirming = PaymentTransaction.with_state(:confirming).load
  confirming.each do |payment_transaction|
    rpc = CoinRPC[payment_transaction.currency]
    raw = rpc.gettransaction(payment_transaction.txid)
    payment_transaction.confirm! raw
  end

  sleep 10
end
