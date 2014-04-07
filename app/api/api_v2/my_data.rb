module APIv2
  class MyData < Grape::API

    desc 'Get your profile and accounts info.'
    get "/my/info" do
      present current_user, with: APIv2::Entities::Member
    end

    desc 'Get your executed trades.'
    params do
      requires :market,    type: String,  values: ::APIv2::Mount::MARKETS
      optional :limit,     type: Integer, default: 50
      optional :timestamp, type: Integer
    end
    get "/my/trades" do
      from = params[:timestamp].present? ? Time.at(params[:timestamp]) : nil
      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], from: from
      )

      present trades, with: APIv2::Entities::Trade
    end

  end
end
