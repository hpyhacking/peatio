class BlackHoleRouter
  include RoutingEssentials

  def call(*)
    not_found!
  end
end
