# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Blockchain.where(status: 'active').each do |bc|
    break unless running
    Rails.logger.info { "Processing #{bc.name} blocks." }
    client    = BlockAPI[:eth]
    processed = 0
    client.sync_transactions(bc)
    Rails.logger.info { "Processing #{bc.name} blocks." }
  rescue => e
    report_exception(e)
  end
  Kernel.sleep 5
end
