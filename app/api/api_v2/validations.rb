module APIv2
  module Validations
    class Range < Grape::Validations::Base
      def initialize(*)
        super
        @range = @option
      end

      def validate_param!(attr, params)
        if (params[attr] || @required) && !@range.cover?(params[attr])
          raise Grape::Exceptions::Validation, \
            params:  [@scope.full_name(attr)],
            message: "must be in range: #{@range}."
        end
      end
    end
  end
end
