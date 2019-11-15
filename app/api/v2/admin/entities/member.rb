# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Member < API::V2::Entities::Member
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique member identifier in database.'
            }
          )

          expose(
            :level,
            documentation: {
              type: Integer,
              desc: 'Member\'s level.'
            }
          )

          expose(
            :role,
            documentation: {
              type: String,
              desc: 'Member\'s role.'
            }
          )


          expose(
            :group,
            documentation: {
              type: String,
              desc: 'Member\'s group.'
            }
          )

          expose(
            :state,
            documentation: {
              type: String,
              desc: 'Member\'s state.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Member created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Member updated time in iso8601 format.'
            }
          )

        end
      end
    end
  end
end
