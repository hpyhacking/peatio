# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        class PaymentAddress < ::API::V2::Entities::PaymentAddress
          expose(
            :uid,
            documentation: {
              type: String,
              desc: 'The shared user ID.'
            }
          ) { |w| w.member.uid }

          expose(
            :remote,
            documentation: {
              type: String,
              desc: 'Payment address remote creation (true/false).'
            }
          )
        end
      end
    end
  end
end
