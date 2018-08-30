# encoding: UTF-8
# frozen_string_literal: true

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

    class ValidateTradeFromTo < Grape::Validations::Base
      def validate_param!(name, params)
        return unless params.key?(name)
        return unless params.key?(:to)
        return if params[name].to_i < params[:to].to_i

        fail Grape::Exceptions::Validation,
             params:  [@scope.full_name(name)],
             message: 'should be less than to.'
      end
    end

    class ValidateCurrencyAddressFormat < Grape::Validations::Base
      def validate_param!(name, params)
        return unless params.key?(name)
        currency = Currency.find_by(id: params[:currency])
        return if currency && currency.blockchain_api.supports_cash_addr_format?

        fail Grape::Exceptions::Validation,
             params:  [@scope.full_name('currency')],
             message: 'does not support cash address format.'
      end
    end
  end
end
