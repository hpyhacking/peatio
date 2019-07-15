# encoding: UTF-8
# frozen_string_literal: true

module HasOneBlockchainThroughCurrency
  extend ActiveSupport::Concern

  included do
    has_one :blockchain, through: :currency
  end

  def transaction_url
    if txid? && blockchain.explorer_transaction.present?
      blockchain.explorer_transaction.gsub('#{txid}', txid)
    end
  end

  def wallet_url
    if blockchain.explorer_address.present?
      blockchain.explorer_address.gsub('#{address}', rid)
    end
  end

  def latest_block_number
    blockchain.blockchain_api.latest_block_number
  end

  def confirmations
    return 0 if block_number.blank?
    return blockchain.processed_height - block_number if (blockchain.processed_height - block_number) >= 0
    'N/A'
  rescue StandardError => e
    report_exception(e)
    'N/A'
  end
end
