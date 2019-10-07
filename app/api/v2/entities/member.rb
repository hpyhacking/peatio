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
          :accounts,
          using: API::V2::Entities::Account,
          documentation: {
            type: 'API::V2::Entities::Account',
            is_array: true,
            desc: 'Member accounts.'
          }
        ) do |m|
            m.accounts.includes(:currency)
          end
      end
    end
  end
end
