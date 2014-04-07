module APIv2
  class Trades < Grape::API

    desc 'Get your executed trades.'
    params do
      requires :market,    type: String,  values: ::APIv2::Mount::MARKETS
      optional :limit,     type: Integer, default: 50
      optional :timestamp, type: Integer
    end
    get "/trades" do
      authenticate!

      from = params[:timestamp].present? ? Time.at(params[:timestamp]) : nil
      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], from: from
      )

      present trades, with: APIv2::Entities::Trade
    end

  end
end
