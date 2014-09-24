#!/usr/bin/env ruby

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
  Withdraw.submitted.each do |withdraw|
    if withdraw.coin?
      currency = withdraw.currency
      fund_uid = withdraw.fund_uid

      begin
        result = CoinRPC[currency].validateaddress(fund_uid)
      rescue
        puts "Error on withdraw: #{$!}"
        puts $!.backtrace.join("\n")
        next
      end

      if result.nil? || (result[:isvalid] == false)
        Rails.logger.info "Withdraw##{withdraw.id} uses invalid address: #{fund_uid.inspect}"
        withdraw.reject!
        next
      elsif (result[:ismine] == true) || PaymentAddress.find_by_address(fund_uid)
        withdraw.reject!
        next
      end
    end

    withdraw.with_lock do
      if withdraw.account.examine
        withdraw.accept!
        withdraw.process! if withdraw.quick?
      else
        withdraw.mark_suspect!
      end
    end
  end

  sleep 5
end
