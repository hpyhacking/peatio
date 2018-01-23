module APIv2
  module Entities
    class Withdraw < Base
      expose :id
      expose(:currency) { |w| w.currency.upcase }
      expose :sum, as: :amount
      expose :fee
      expose :txid
      expose :fund_uid, as: :address
      expose :state do |withdraw|
        case withdraw.aasm_state
          when :canceled                            then :cancelled
          when :suspect                             then :suspected
          when :rejected, :accepted, :done, :failed then withdraw.aasm_state
          when :processing, :almost_done            then :processing
          else :submitted
        end
      end
      expose :created_at, :updated_at, :done_at, format_with: :iso8601
    end
  end
end
