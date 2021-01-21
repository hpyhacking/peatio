# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class InternalTransfer < API::V2::Entities::InternalTransfer
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Internal transfer uniq id'
            }
          )
        end
      end
    end
  end
end
