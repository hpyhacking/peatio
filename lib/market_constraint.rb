class MarketConstraint
  def self.matches?(request)
    id = request.path_parameters[:market_id] || request.path_parameters[:id]
    market = Market.find_by_id(id)
    if market
      request.path_parameters[:market] = id
      request.path_parameters[:ask] = market.base_unit
      request.path_parameters[:bid] = market.quote_unit
    else
      false
    end
  end
end

