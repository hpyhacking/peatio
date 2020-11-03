# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Base < Grape::Entity
        format_with(:iso8601) {|t| t.to_time.in_time_zone(Rails.configuration.time_zone).iso8601 if t }
        format_with(:decimal) {|d| d.to_s('F') if d }
      end
    end
  end
end
