module Currencible
  extend ActiveSupport::Concern

  included do
    belongs_to :currency, required: true
    scope :with_currency, -> (model_or_code) do
      model = Currency === model_or_code ? model_or_code : Currency.find_by!(code: model_or_code)
      where(currency: model)
    end
  end
end
