require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running do
  Deposits::Coin.recent.where(aasm_state: :submitted).limit(100).each do |deposit|
    break unless running
    begin
      confirmations = deposit.currency.api.load_deposit!(deposit.txid).fetch(:confirmations)
      deposit.with_lock do
        deposit.update!(confirmations: confirmations)
        deposit.accept! if confirmations >= deposit.currency.deposit_confirmations
      end
    rescue => e
      report_exception(e)
    end
  end

  Kernel.sleep 5
end
