# encoding: UTF-8
# frozen_string_literal: true

class BlackHoleRouter
  include RoutingEssentials

  def call(*)
    not_found!
  end
end
