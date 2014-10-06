module ChartHelper

  def render_market_chart
    gon.kline_data = KlineDB.kline(current_market.id, 1)
    render partial: 'shared/market/chart', locals: {market: current_market.name}
  end

end
