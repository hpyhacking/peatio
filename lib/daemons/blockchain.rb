# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Blockchain.active.tap do |blockchains|
    if ENV.key?('BLOCKCHAINS')
      blockchain_keys = ENV.fetch('BLOCKCHAINS').split(',').map(&:squish).reject(&:blank?)
      blockchains.where!(key: blockchain_keys)
    end
  end.find_each do |bc|

    break unless running
    Rails.logger.info { "Processing #{bc.name} blocks." }

    blockchain = BlockchainService.new(bc)
    latest_block = blockchain.latest_block_number

    # Don't start process if we didn't receive new blocks.
    if bc.height + bc.min_confirmations >= latest_block
      Rails.logger.info { "Skip synchronization. No new blocks detected height: #{bc.height}, latest_block: #{latest_block}" }
      next
    end

    from_block   = bc.height || 0
    to_block     = [latest_block, from_block + bc.step].min
    (from_block..to_block).each do |block_id|

      Rails.logger.info { "Started processing #{bc.key} block number #{block_id}." }

      block_json = blockchain.process_block(block_id)
      Rails.logger.info { "Fetch #{block_json.transactions.count} transactions in block number #{block_id}." }
      Rails.logger.info { "Finished processing #{bc.key} block number #{block_id}." }
    end
    Rails.logger.info { "Finished processing #{bc.name} blocks." }
  rescue => e
    report_exception(e)
  end
  Kernel.sleep 5
end
