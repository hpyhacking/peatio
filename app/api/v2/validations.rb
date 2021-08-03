# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Validations
      # TODO: Update params validation by overriding message method.
      # New message structure is "#{PREFIX}.#{REASON}#{ATTRIBUTE}" e.g "account.withdraw.invalid_amount"

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

      # overrides default Grape PresenceValidator class methods
      class PresenceValidator < Grape::Validations::PresenceValidator
        # Default exception is costructed from `@api` class name.
        # E.g
        # @api.class  => API::V2::Account::Withdraws
        # default_message => "account.withdraw.missing_otp"

        def message(_param)
          api = @scope.instance_variable_get(:@api)
          module_name = api.base.parent.name.humanize.demodulize
          class_name = api.base.name.humanize.demodulize.singularize
          # Return default API error message for Management module (no errors unify).
          return super if module_name == 'management'

          options_key?(:message) ? @option[:message] : default_exception(module_name, class_name)
        end

        def default_exception(module_name, class_name)
          "#{module_name}.#{class_name}.missing_#{attrs.first}"
        end
      end

      # overrides default Grape AllowBlankValidator class methods
      class AllowBlankValidator < Grape::Validations::AllowBlankValidator
        # Default exception is costructed from `@api` class name.
        # E.g
        # @api.class  => API::V2::Account::Withdraws
        # default_message => "account.withdraw.empty_otp"

        def message(_param)
          api = @scope.instance_variable_get(:@api)
          module_name = api.base.parent.name.humanize.demodulize
          class_name = api.base.name.humanize.demodulize.singularize
          # Return default API error message for Management module (no errors unify).
          return super if module_name == 'management'

          options_key?(:message) ? @option[:message] : default_exception(module_name, class_name)
        end

        def default_exception(module_name, class_name)
          "#{module_name}.#{class_name}.empty_#{attrs.first}"
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

      class ValidateCurrencyAddressFormat < Grape::Validations::Base

        REASON ||= 'doesnt_support_cash_address_format'
        def validate_param!(name, params)
          return unless params.key?(name)

          blockchain_currency = BlockchainCurrency.find_network(params[:blockchain_key], params[:currency])
          return if blockchain_currency && blockchain_currency.blockchain_api.supports_cash_addr_format?

          fail Grape::Exceptions::Validation,
              params:  [@scope.full_name('currency')],
              message: "#{@option.fetch(:prefix)}.#{REASON}"
        end
      end
    end
  end
end
