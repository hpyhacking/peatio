# encoding: UTF-8
# frozen_string_literal: true

class AdminOperationsRouter < CRUDRouter
  def initialize type
    @type = type.to_s
  end

  def call(env)
    controller = "admin/operations/#{@type.pluralize}_controller".camelize.constantize
    actions    = %i[ index ]
    action(env).in?(actions) ? controller.action(action(env)).call(env) : not_found!
  end
end
