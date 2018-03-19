class AdminDepositsRouter < CRUDRouter
  def call(env)
    currency   = Currency.find_by_code!(params(env)[:currency])
    controller = "admin/deposits/#{currency.type.pluralize}_controller".camelize.constantize
    actions    = currency.fiat? ? %i[ new index show create update ] : %i[ index update ]
    action(env).in?(actions) ? controller.action(action(env)).call(env) : not_found!
  end
end
