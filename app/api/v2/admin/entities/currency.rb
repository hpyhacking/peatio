# enco  ding: UTF-8
# froz  en_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Currency < API::V2::Entities::Currency
          unexpose(:id)

          expose(
            :code,
            documentation: {
              desc: 'Unique currency code.',
              type: String
            }
          )

          expose(
            :status,
            documentation: {
              type: String,
              desc: 'Currency display status (enabled/disabled/hidden).'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
