class AdminWithdrawsRouter < CRUDRouter
  def call(env)
    currency   = Currency.find_by_code!(params(env)[:currency])
    controller = "admin/withdraws/#{currency.type.pluralize}_controller".camelize.constantize
    actions    = %i[ index show update destroy ]
    action(env).in?(actions) ? controller.action(action(env)).call(env) : not_found!
  end
end
