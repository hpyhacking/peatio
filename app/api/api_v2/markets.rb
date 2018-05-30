# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Markets < Grape::API

    desc 'Get all available markets.'
    get "/markets" do
      present Market.enabled.ordered, with: APIv2::Entities::Market
    end

  end
end
