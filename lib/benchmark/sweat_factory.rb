module Benchmark
  class SweatFactory

    @@seq = 0

    class <<self
      def make_member
        @@seq += 1
        member = Member.create!(
          email: "user#{@@seq}@example.com",
          name: "Matching Benchmark #{@@seq}"
        )
      end

      def make_order(klass, attrs={})
        klass.new({
          bid: :cny,
          ask: :btc,
          state: Order::WAIT,
          currency: :btccny,
          origin_volume: attrs[:volume],
          source: 'Web'
        }.merge(attrs))
      end
    end

  end
end
