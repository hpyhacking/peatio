# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Member < Base
        expose(
          :uid,
          documentation: {
            type: String,
            desc: 'Member UID.'
          }
        )

        expose(
          :email,
          documentation: {
            type: String,
            desc: 'Member email.'
          }
        )

        expose(
          :group,
          documentation: {
            type: String,
            desc: 'Member\'s group.'
          }
        )
      end
    end
  end
end
