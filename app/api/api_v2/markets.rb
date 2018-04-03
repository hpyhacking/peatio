module APIv2
  class Markets < Grape::API

    desc 'Get all available markets.'
    get "/markets" do
      present Market.visible, with: APIv2::Entities::Market
    end

  end
end
