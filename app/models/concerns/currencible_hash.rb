module CurrencibleHash
  extend ActiveSupport::Concern

  included do
    def currency
      Currency.find_by_code(attributes[:currency])
    end

    def currency_value
      attributes[:currency].to_sym
    end

    alias :currency_obj :currency
  end
end
