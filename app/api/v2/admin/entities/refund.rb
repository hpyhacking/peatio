# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Refund < API::V2::Entities::Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'The refund id'
            }
          )

          expose(
            :address,
            documentation: {
              type: String,
              desc: 'Refund address'
            }
          )

          expose(
            :deposit,
            using: API::V2::Admin::Entities::Deposit
          )
        end
      end
    end
  end
end
