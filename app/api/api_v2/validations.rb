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

    class IntegerGTZero < Grape::Validations::Base
      def validate_param!(name, params)
        return unless params.key?(name)
        return if params[name].to_s.to_i > 0

        fail Grape::Exceptions::Validation,
             params:  [@scope.full_name(name)],
             message: "#{name} must be greater than zero."
      end
    end
  end
end
