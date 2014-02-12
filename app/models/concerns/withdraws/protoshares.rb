module Concerns
  module Withdraws
    module Protoshares
      extend ActiveSupport::Concern

      def _fix_protoshares_fee
        self.sum = self.sum.round(8, 2)
        self.fee = '0.0005'.to_d
      end
    end
  end
end



