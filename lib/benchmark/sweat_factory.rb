
module Benchmark
  class SweatFactory

    class <<self
      def make_member
        member = Member.create!(
          email: Faker::Internet.unique.email
        )
      end

      def make_order(klass, attrs={})
        klass.new({
          bid: fiat_currency.id,
          ask: coin_currency.id,
          state: Order::WAIT,
          market_id: "#{coin_currency.code}#{fiat_currency.code}".to_sym,
          origin_volume: attrs[:volume],
          ord_type: "limit"
        }.merge(attrs))
      end

      def fiat_currency
        @fiat_currency ||= Currency.fiats.first
      end

      def coin_currency
        @coin_currency ||= Currency.coins.first
      end
    end

  end
end
