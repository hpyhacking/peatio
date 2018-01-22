require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running do
  PaymentTransaction::Normal.with_aasm_state(:unconfirm, :confirming).find_each do |tx|
    begin
      tx.with_lock { tx.check! }
    rescue => e
      report_exception(e)
    end
  end

  Kernel.sleep 5
end
