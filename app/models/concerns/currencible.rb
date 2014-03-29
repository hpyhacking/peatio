module Currencible
  extend Enumerize
  extend ActiveSupport::Concern
  extend ActiveHash::Associations::ActiveRecordExtensions

  included do
    enumerize :currency, in: Currency.codes, scope: true
    belongs_to :currency_obj, class_name: 'Currency', foreign_key: 'currency_value'
  end
end
