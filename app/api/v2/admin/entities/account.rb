# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Account < API::V2::Entities::Account
          expose(
            :deposit_address,
            documentation: {
              type: String,
              desc: 'Deposit address.'
            }
          ) do |account|
            account.payment_address&.address
          end
        end
      end
    end
  end
end
