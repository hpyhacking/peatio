module APIv2
  module Entities
    class WithdrawDestination < Base
      expose :id
      expose(:currency) { |w| w.currency.code }
      expose :label
      expose (:type) { |w| w.class.name.demodulize.underscore }

      %w[ fiat coin ].each do |type|
        "withdraw_destination/#{type}".camelize.constantize.fields.each do |field, desc|
          expose(field, documentation: desc) { |w| w.try(field) }
        end
      end
    end
  end
end
