# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'authorization/bearer'

class ApplicationController < ActionController::Base
  include Authorization::Bearer
  extend Memoist

  before_action :set_ets_context!, if: -> { defined?(Raven) }

  helper_method :is_admin?, :current_user

  private

  def current_user
    if request.headers['Authorization']
      token = request.headers['Authorization']
      payload = authenticate!(token)
      Member.from_payload(payload)
    end
  end
  memoize :current_user

  def auth_member!
    not_found unless current_user
  end

  def auth_anybody!
    not_found if current_user
  end

  def auth_admin!
    not_found unless is_admin?
  end

  def not_found
    render plain: '404 Not Found', status: 404
  end

  def is_admin?
    current_user.role.in?(Member::ADMIN_ROLES)
  end

  def set_ets_context!
    Raven.tags_context(
      email: current_user.email,
      uid: current_user.uid,
      role: current_user.role,
      peatio_version: Peatio::Application::VERSION
    )
  end
end
