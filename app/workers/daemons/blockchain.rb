# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class Blockchain < Base
      # TODO: Start synchronization of blockchains created in run-time.
      def run
        lock(self.class, 0) { ::Blockchain.active.map { |b| Thread.new { process(b) } }.map(&:join) }
      end

      def process(bc)
        bc_service = BlockchainService.new(bc)

        logger.info { "Processing #{bc.name} blocks." }

        while running
          begin
            # Reset blockchain_service state.
            bc_service.reset!

            if bc.reload.height + bc.min_confirmations >= bc_service.latest_block_number
              logger.info { "Skip synchronization. No new blocks detected, height: #{bc.height}, latest_block: #{bc_service.latest_block_number}." }
              logger.info { 'Sleeping for 10 seconds' }
              sleep(10)
              next
            end

            from_block = bc.height || 0

            (from_block..bc_service.latest_block_number).each do |block_id|
              break unless running

              logger.info { "Started processing #{bc.key} block number #{block_id}." }
              block_json = bc_service.process_block(block_id)
              logger.info { "Fetch #{block_json.transactions.count} transactions in block number #{block_id}." }
              logger.info { "Finished processing #{bc.key} block number #{block_id}." }
            end
          rescue StandardError => e
            raise e if is_db_connection_error?(e)

            report_exception(e)
            logger.warn { "Error: #{e}. Sleeping for 10 seconds" }
            sleep(10)
          end
        end

        logger.info { "Finished processing #{bc.name} blocks." }
      end
    end
  end
end
