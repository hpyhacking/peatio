require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running do
  PaymentTransaction::Normal.with_aasm_state(:unconfirm, :confirming).find_each do |tx|
    begin
      tx.with_lock { tx.check! }
    rescue => e
      Kernel.print e.inspect, "\b", e.backtrace.join("\n"), "\n\n"
    end
  end

  Kernel.sleep 5
end
