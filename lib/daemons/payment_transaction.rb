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

  Rails.logger.debug "=========================================="

  txs = PaymentTransaction.with_aasm_state(:unconfirm, :confirming)
  txs.each do |tx|
    Rails.logger.debug "------- ##{tx.id} -------"
    ActiveRecord::Base.transaction do tx.check!  end
    Rails.logger.debug "======= ##{tx.id} ======="
  end

  sleep 5
end
