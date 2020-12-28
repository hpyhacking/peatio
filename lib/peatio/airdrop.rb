# frozen_string_literal: true

module Peatio
  class Airdrop
    def process(src_user, params)
      Transfer.transaction do
        CSV.parse(params[:file][:tempfile], headers: true, quote_empty: false).each do |row|
          row = row.to_h.compact.symbolize_keys!
          currency = Currency.find(row[:currency_id])
          amount = row[:amount]
          credited_user = Member.find_by_uid(row[:uid])
          next if credited_user.blank?

          code = currency.coin? ? 202 : 201
          liabilities = [
            Operations::Liability.new(
              code: code,
              currency: currency,
              debit: amount,
              member_id: src_user.id
            ),
            Operations::Liability.new(
              code: code,
              currency: currency,
              credit: amount,
              member_id: credited_user.id
            )
          ]

          Transfer.create!(
            key: "#{credited_user.uid}_#{currency.id}_#{Time.now.to_i}",
            category: 'airdrop',
            description: "Transfer from #{src_user.uid} to #{credited_user.uid} currency_id: #{currency.id}, amount: #{amount}",
            liabilities: liabilities
          )
        end
      end
    rescue StandardError => e
      Rails.logger.error { e.message }
    end
  end
end
