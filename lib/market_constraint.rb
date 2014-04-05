class MarketConstraint
  def self.matches?(request)
    id = request.path_parameters[:market_id] || request.path_parameters[:id]
    if market = Market.find_by_id(id)
      request.path_parameters[:market] = id
      request.path_parameters[:ask] = market.target_unit
      request.path_parameters[:bid] = market.price_unit
    else
      false
    end
  end
end

