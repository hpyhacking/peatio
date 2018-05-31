# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  module Entities
    class Deposit < Base
      expose :tid, documentation: { type: Integer, desc: 'The shared transaction ID.' }
      expose :currency_id, as: :currency, documentation: { type: String, desc: 'The currency code.' }
      expose(:uid, documentation: { type: String, desc: 'The shared user ID.' }) { |w| w.member.uid }
      expose(:type, documentation: { type: String, desc: 'The deposit type (fiat or coin).' }) { |d| d.class.name.demodulize.underscore }
      expose :amount, documentation: { type: String, desc: 'The deposit amount.' }, format_with: :decimal
      states = [
        '«submitted» – initial state.',
        '«canceled» – deposit has been canceled by outer service.',
        '«rejected» – deposit has been rejected by outer service..',
        '«accepted» – deposit has been accepted by outer service, money are loaded.'
      ]
      expose :aasm_state, as: :state, documentation: { type: String, desc: 'The deposit state. ' + states.join(' ') }
      expose :created_at, format_with: :iso8601, documentation: { type: String, desc: 'The datetime when deposit was created.' }
      expose :completed_at, format_with: :iso8601, documentation: { type: String, desc: 'The datetime when deposit was completed.' }
      expose :txid, as: :blockchain_txid, if: -> (d, _) { d.coin? }, documentation: { type: String, desc: 'The transaction ID on the Blockchain (coin only).' }
      expose :confirmations, as: :blockchain_confirmations, if: -> (d, _) { d.coin? }, documentation: { type: String, desc: 'The number of transaction confirmations on the Blockchain (coin only).' }
    end
  end
end
