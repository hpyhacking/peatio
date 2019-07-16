# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class Blockchain < Base
      def run
        ::Blockchain.active.map do |bc|
          Thread.new {process(bc)}
        end.map(&:join)
      end

      def process(bc)
        bc_service = BlockchainService.new(bc)

        while running
          begin
            logger.info {"Processing #{bc.name} blocks."}

            latest_block = bc_service.latest_block_number

            if bc.reload.height + bc.min_confirmations >= latest_block
              logger.info {"Skip synchronization. No new blocks detected, height: #{bc.height}, latest_block: #{latest_block}. Sleeping for 10 seconds"}
              sleep(10)
              next
            end

            from_block = bc.height || 0
            to_block = [latest_block, from_block + bc.step].min

            (from_block..to_block).each do |block_id|
              logger.info {"Started processing #{bc.key} block number #{block_id}."}
              block_json = bc_service.process_block(block_id)
              logger.info {"Fetch #{block_json.transactions.count} transactions in block number #{block_id}."}
              logger.info {"Finished processing #{bc.key} block number #{block_id}."}
            end
            logger.info {"Finished processing #{bc.name} blocks."}
          rescue StandardError => e
            report_exception(e)
            logger.warn {"Error: #{e}. Sleeping for 10 seconds"}
            sleep(10)
          end
        end
      end
    end
  end
end
