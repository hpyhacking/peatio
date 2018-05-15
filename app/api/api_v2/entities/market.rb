# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Market < Base
      expose :id, documentation: "Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets."
      expose :name
    end
  end
end
