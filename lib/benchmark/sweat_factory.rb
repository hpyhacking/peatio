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
          bid: Currency.fiats.first.code_ccy_sym,
          ask: :btc,
          state: Order::WAIT,
          currency: "btc#{Currency.fiats.first.code_ccy}".to_sym,
          origin_volume: attrs[:volume],
          source: 'Web'
        }.merge(attrs))
      end
    end

  end
end
