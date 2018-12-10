# frozen_string_literal: true

module API
  module V2
    module Public
      class Mount < Grape::API

        mount Public::Fees
        mount Public::Currencies
        mount Public::Markets
        mount Public::MemberLevels
        mount Public::Tools
      end
    end
  end
end
