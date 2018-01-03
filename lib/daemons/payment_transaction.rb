require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  PaymentTransaction::Normal.with_aasm_state(:unconfirm, :confirming).each do |tx|
    begin
      tx.with_lock do
        tx.check!
      end
    rescue
      puts "Error on PaymentTransaction::Normal: #{$!}"
      puts $!.backtrace.join("\n")
      next
    end
  end

  sleep 5
end
