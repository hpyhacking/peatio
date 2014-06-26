module APIv2
  class K < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get OHLC(k line) of specific market.'
    params do
      use :market
      optional :limit,     type: Integer, default: 30, values: 1..100, desc: "Limit the number of returned data points, default to 30."
      optional :period,    type: Integer, default: 1, values: [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080], desc: "Time period of K line, default to 1."
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
    end
    get "/k" do
      key = "peatio:#{params[:market]}:k:#{params[:period]}"

      if params[:timestamp]
        ts = JSON.parse(redis.lindex(key, 0)).first
        offset = (params[:timestamp] - ts) / 60 / params[:period]
        offset = 0 if offset < 0

        redis.lrange(key, offset, offset + params[:limit] - 1).map{|str| JSON.parse(str)}
      else
        length = redis.llen(key)
        redis.lrange(key, length - params[:limit], -1).map{|str| JSON.parse(str)}
      end
    end
  end
end
