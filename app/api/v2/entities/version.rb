# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Version < Base
        expose(:git_sha,
               documentation: {
                 type: String,
                 desc: 'Running Peatio git commit SHA.'
               }
        )
        expose(:git_tag,
               documentation: {
                 type: String,
                 desc: 'Running Peatio git tag.'
               }
        )
        expose(:build_date,
               format_with: :iso8601,
               documentation: {
                 type: String,
                 desc: 'Running Peatio build date in iso8601 format'
               }
        )
        expose(:version,
               documentation: {
                 type: String,
                 desc: 'Running Peatio version'
               }
        )
      end
    end
  end
end
