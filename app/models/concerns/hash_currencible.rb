module HashCurrencible
  extend ActiveSupport::Concern

  included do
    def currency
      Currency.find_by!(code: attributes[:currency])
    end
  end
end
