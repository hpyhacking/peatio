module ManagementAPIv1
  module Entities
    class WithdrawDestination < Base
      expose :id, documentation: { type: Integer, desc: 'The withdraw destination ID.' }
      expose(:currency, documentation: { type: String, desc: 'The currency code.' }) { |w| w.currency.code }
      expose(:uid, documentation: { type: String, desc: 'The shared user ID.' }) { |w| w.member.authentications.barong.first.uid }
      expose :label, documentation: { type: String, desc: 'The associated label.' }
      expose(:type, documentation: { type: String, desc: 'The withdraw destination type (fiat or coin).' }) { |w| w.class.name.demodulize.underscore }
      %w[ fiat coin ].each do |type|
        "withdraw_destination/#{type}".camelize.constantize.fields.each do |field, desc|
          expose(field, documentation: { type: String, desc: desc }, if: -> (w, _) { w.respond_to?(field) }) { |w| w.public_send(field) }
        end
      end
    end
  end
end
