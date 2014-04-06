# This constraint is created to keep API v1 working after market id fix
# (cnybtc -> btccny), so api users could continue send request with old
# market id 'cnybtc', e.g.
#
#   GET /api/tickers/cnybtc
#
# will have the same effect as
#
#   GET /api/tickers/btccny

class APIMarketConstraint
  def self.matches?(request)
    id = request.path_parameters[:market_id] || request.path_parameters[:id]

    if id == 'cnybtc'
      id = 'btccny'
      request.path_parameters[:market_id] = 'btccny' if request.path_parameters[:market_id] == 'cnybtc'
      request.path_parameters[:id] = 'btccny' if request.path_parameters[:id] == 'cnybtc'
    end

    if market = Market.find_by_id(id)
      request.path_parameters[:market] = id
      request.path_parameters[:ask] = market.target_unit
      request.path_parameters[:bid] = market.price_unit
    else
      false
    end
  end
end
