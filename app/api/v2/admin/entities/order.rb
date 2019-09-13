# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Order < API::V2::Entities::Order
          unexpose(:trades)

          expose(
            :email,
            documentation: {
              type: String,
              desc: 'The shared user email.'
            }
          ) { |w| w.member.email }

          expose(
            :uid,
            documentation: {
              type: String,
              desc: 'The shared user ID.'
            }
          ) { |w| w.member.uid }
        end
      end
    end
  end
end
