module APIv2
  class Tickers < Grape::API

    desc 'Get ticker of specific market.'
    params do
      requires :market, type: String,  values: Market.all.map(&:id)
    end
    get "/tickers/:market" do
      ticker = Global[params[:market]].ticker

      { at: ticker[:at],
        ticker: {
          buy: ticker[:buy],
          sell: ticker[:sell],
          low: ticker[:low],
          high: ticker[:high],
          last: ticker[:last],
          vol: ticker[:volume]
        }
      }
    end

  end
end
