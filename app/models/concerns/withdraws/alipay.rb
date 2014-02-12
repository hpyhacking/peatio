module Concerns
  module Withdraws
    module Alipay
      extend ActiveSupport::Concern

      def _fix_alipay_fee
        fix = 2
        self.sum = self.sum.round(fix, 2)
        self.fee = self.sum * '0.01'.to_d
        self.fee = self.fee.round(fix, 2)
      end

      def _valid_alipay_sum
        if self.sum < 500
          return :min
        end
        if self.sum > 5000
          return :max
        end
      end
    end
  end
end

