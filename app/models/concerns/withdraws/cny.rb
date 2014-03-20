module Concerns
  module Withdraws
    module CNY
      extend ActiveSupport::Concern

      def _fix_cny_fee
        fix = 2
        self.sum = self.sum.round(fix, 2)
        self.fee = self.sum * '0.003'.to_d
        self.fee = self.fee.round(fix, 2)
      end

      def _valid_bank_sum
        unless self.sum > 100
          return :min
        end
      end
    end
  end
end

