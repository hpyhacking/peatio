# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Beneficiary < API::V2::Entities::Beneficiary
          expose(
            :data,
            documentation: {
              desc: 'Bank Account details for fiat Beneficiary in JSON format.'\
                    'For crypto it\'s blockchain address.',
              type: JSON
            }
          )

          expose(
            :protocol,
            documentation: {
              desc: 'Blockchain protocol',
            }, if: -> (beneficiary){ beneficiary.blockchain.present? }
          ) { |beneficiary| beneficiary.blockchain.protocol }
        end
      end
    end
  end
end
