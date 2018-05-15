# encoding: UTF-8
# frozen_string_literal: true

class CRUDRouter
  include RoutingEssentials

  def call(env)
    method_not_implemented
  end

protected

  def action(env)
    case env['REQUEST_METHOD']
      when 'GET'
        if params(env)[:id].present?
          :show
        else
          env['REQUEST_PATH'].end_with?('/new') ? :new : :index
        end
      when 'POST' then :create
      when 'PUT', 'PATCH' then :update
      when 'DELETE' then :destroy
    end
  end

  def params(env)
    env['action_dispatch.request.path_parameters']
  end
end
