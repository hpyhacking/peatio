# frozen_string_literal: true

module API::V2
  module Market
    class Mount < Grape::API
      helpers ::API::V2::OrderHelpers

      before { authenticate! }
      before { trading_must_be_permitted! }
      before { set_ets_context! }

      mount Market::Orders
      mount Market::Trades
    end
  end
end
