module APIv2
  module Entities
    module Solvency
      class Proof < Base
        expose :id
        expose(:currency)  { |a| a.currency.code }
        expose(:type)      { |a| a.currency.type }
        expose :sum
        expose :addresses
        expose :balance
        expose :created_at
      end
    end
  end
end
