# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        class Base < Grape::Entity
          format_with(:iso8601) { |t| t.iso8601 if t }
          format_with(:decimal) { |d| d.to_s('F') if d }
        end
      end
    end
  end
end