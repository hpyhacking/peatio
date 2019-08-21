module API
  module V2
    module Management
      module Entities
        class Member < Base
          expose(
            :uid,
            documentation: {
              type: String,
              desc: 'The shared user ID.'
            }
          )

          expose(
            :email,
            documentation: {
              type: String,
              desc: 'User email.'
            }
          )

          expose(
            :level,
            documentation: {
              type: Integer,
              desc: 'User level.'
            }
          )

          expose(
            :role,
            documentation: {
              type: String,
              desc: 'User role.'
            }
          )

          expose(
            :group,
            documentation: {
              type: String,
              desc: 'User group (vip-0, vip-1, etc).'
            }
          )

          expose(
            :state,
            documentation: {
              type: String,
              desc: 'User state (active/pending/banned).'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'User create time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
