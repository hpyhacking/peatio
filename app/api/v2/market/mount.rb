# frozen_string_literal: true

module API::V2
  module Market
    class Mount < Grape::API

      before { authenticate! }
      before { trading_must_be_permitted! }

      mount Market::Orders
      mount Market::Trades
    end
  end
end
