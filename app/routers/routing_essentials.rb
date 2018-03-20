module RoutingEssentials
  def not_found!
    raise ActionController::RoutingError, 'The URL you requested was not found.'
  end
end
