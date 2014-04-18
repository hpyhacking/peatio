module APIv2
  module Validations
    class Range < ::Grape::Validations::Validator

      def initialize(attrs, options, required, scope)
        @range    = options
        @required = required
        super
      end

      def validate_param!(attr_name, params)
        if (params[attr_name] || @required) && !@range.cover?(params[attr_name])
          raise Grape::Exceptions::Validation, param: @scope.full_name(attr_name), message: "must be in range: #{@range}"
        end
      end

    end
  end
end
