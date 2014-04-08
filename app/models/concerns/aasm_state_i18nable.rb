module AasmStateI18nable
  extend ActiveSupport::Concern

  included do
    enumerize :aasm_state, in: Deposit::STATE, scope: true, i18n_scope: "#{name.underscore}.aasm_state"
  end
end

