module APIv2
  module Entities
    class Base < Grape::Entity
      format_with(:iso8601) {|t| t.iso8601 }
    end
  end
end
