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
  logger = Logger.new(STDOUT)

  withdraws = Withdraw.with_state(:coin_ready).load

  withdraws.each do |w|
    logger.debug "begin #{w.id} amount: #{w.amount} address: #{w.address}"
    balance = CoinRPC[w.currency].getbalance.to_d

    if balance >= w.amount
      logger.debug "check balance ok -> #{balance}"
      Resque.enqueue(Job::Coin, w.id)
      sleep 2
    else
      logger.debug "check balance error -> send warning mail"
      SystemMailer.balance_warning(w.amount, balance).deliver
      sleep 300
      logger.debug "break all withdraws"
      break
    end
  end

  logger.debug "next loop -> sleep"
  sleep 10
  logger.debug "loop daemons"
end
