module APIv2
  module Entities
    class Base < Grape::Entity
      format_with(:iso8601) {|t| t.iso8601 }
      format_with(:decimal) {|d| d.to_s('F') }
    end
  end
end
