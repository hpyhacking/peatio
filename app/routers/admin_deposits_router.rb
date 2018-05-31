# encoding: UTF-8
# frozen_string_literal: true

class AdminDepositsRouter < CRUDRouter
  def call(env)
    currency   = Currency.find(params(env)[:currency])
    controller = "admin/deposits/#{currency.type.pluralize}_controller".camelize.constantize
    actions    = currency.fiat? ? %i[ new index show create update ] : %i[ index update ]
    action(env).in?(actions) ? controller.action(action(env)).call(env) : not_found!
  end
end
