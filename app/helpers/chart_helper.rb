module ChartHelper

  def set_gon_kline_data
    key = "peatio:#{current_market.id}:k:1"
    length = RedisCache.kline.llen(key)
    data = RedisCache.kline.lrange(key, length - 5000, -1).map{|str| JSON.parse(str)}
    gon.kline_data = data
  end

  def render_market_chart
    set_gon_kline_data
    render partial: 'shared/market/chart'
  end

end
