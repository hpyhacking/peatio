class MarketConstraint
  def self.matches?(request)
    id = request.path_parameters[:market_id] || request.path_parameters[:id]
    if Market.enumerize.keys.include?(id.to_sym)
      request.path_parameters[:market] = id
      request.path_parameters[:bid] = id[0..2]
      request.path_parameters[:ask] = id[3..5]
    else
      false
    end
  end
end

