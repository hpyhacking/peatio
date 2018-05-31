# encoding: UTF-8
# frozen_string_literal: true

class AdminWithdrawsRouter < CRUDRouter
  def call(env)
    currency   = Currency.find(params(env)[:currency])
    controller = "admin/withdraws/#{currency.type.pluralize}_controller".camelize.constantize
    actions    = %i[ index show update destroy ]
    action(env).in?(actions) ? controller.action(action(env)).call(env) : not_found!
  end
end
