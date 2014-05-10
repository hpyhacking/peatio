module AasmAbsolutely
  extend ActiveSupport::Concern

  included do
    enumerize :aasm_state, in: self.superclass::STATES, scope: true, i18n_scope: "#{name.underscore}.aasm_state"
  end
end
