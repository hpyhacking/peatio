# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        class Withdraw < Base
          expose :tid, documentation: { type: Integer, desc: 'The shared transaction ID.' }
          expose(:uid, documentation: { type: String, desc: 'The shared user ID.' }) { |w| w.member.uid }
          expose :currency_id, as: :currency, documentation: { type: String, desc: 'The currency code.' }
          expose :note, documentation: { type: String, desc: 'The note for withdraw.' }
          expose(:type, documentation: { type: String, desc: 'The withdraw type (fiat or coin).' }) { |w| w.class.name.demodulize.underscore }
          expose :amount, documentation: { type: String, desc: 'The withdraw amount excluding fee.' }, format_with: :decimal
          expose :fee, documentation: { type: String, desc: 'The exchange fee.' }, format_with: :decimal
          expose :rid, documentation: { type: String, desc: 'The beneficiary ID or wallet address on the Blockchain.' }
          expose :blockchain_key, documentation: { type: String, desc: 'Unique key to identify blockchain.' }
          states = [
            '«prepared» – initial state, money are not locked.',
            '«submitted» – withdraw has been allowed by outer service for further validation, money are locked.',
            '«canceled» – withdraw has been canceled by outer service, money are unlocked.',
            '«accepted» – system has validated withdraw and queued it for processing by worker, money are locked.',
            '«rejected» – system has validated withdraw and found errors, money are unlocked.',
            '«processing» – worker is processing withdraw as the current moment, money are locked.',
            '«skipped» – worker skipped withdrawal in case of insufficient balance of hot wallet or it absence.',
            '«succeed» – worker has successfully processed withdraw, money are subtracted from the account.',
            '«failed» – worker has encountered an unhandled error while processing withdraw, money are unlocked.'
          ]
          expose :aasm_state, as: :state, documentation: { type: String, desc: 'The withdraw state. ' + states.join(' ') }
          expose :created_at, format_with: :iso8601, documentation: { type: String, desc: 'The datetime when withdraw was created.' }
          expose :txid, as: :blockchain_txid, documentation: { type: String, desc: 'The transaction ID on the Blockchain (coin only).' }, if: -> (w, _) { w.currency.coin? }
          expose :transfer_type, documentation: { type: String, desc: 'withdraw transfer_type.' }
        end
      end
    end
  end
end
