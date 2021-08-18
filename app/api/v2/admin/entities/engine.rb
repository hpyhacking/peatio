# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Engine < API::V2::Entities::Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Engine uniq id'
            }
          )

          expose(
            :name,
            documentation: {
              type: String,
              desc: 'Engine name'
            }
          )

          expose(
            :driver,
            documentation: {
              type: String,
              desc: 'Engine driver'
            }
          )

          expose(
            :uid,
            documentation: {
              type: String,
              desc: 'Owner of a engine'
            }
          )

          expose(
            :url,
            documentation: {
              type: String,
              desc: 'Engine url'
            }
          )

          expose(
            :state,
            documentation: {
              type: String,
              desc: 'Engine state'
            }
          )
        end
      end
    end
  end
end
