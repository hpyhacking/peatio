class Ordering
  PRICE_RANGE = ("0.01".to_d.."100".to_d)
  class LatestPriceError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  def member
    @member ||= Member.find(@order.member_id)
  end

  def check_latest_price
    latest = Trade.latest_price(@order.currency)
    latest.zero? || PRICE_RANGE.cover?(@order.price / latest)
  end

  def submit
    unless check_latest_price
      @order.errors.add(:price, :range)
      raise LatestPriceError, "invalid price"
    end

    ActiveRecord::Base.transaction do
      @order.save!

      account = @order.hold_account.lock!
      account.lock_funds(@order.sum, reason: Account::ORDER_SUBMIT, ref: @order)

      AMQPQueue.enqueue(:matching, action: 'submit', order: @order.to_matching_attributes)
    end

    raise unless @order.errors.empty?
    return true
  end

  def cancel
    ActiveRecord::Base.transaction do
      order = Order.find(@order.id).lock!
      account = @order.hold_account.lock!

      if order.state == Order::WAIT
        order.state = Order::CANCEL
        account.unlock_funds(order.sum, reason: Account::ORDER_CANCEL, ref: order)
        order.save!

        AMQPQueue.enqueue(:matching, action: 'cancel', order: @order.to_matching_attributes)
        true
      else
        false
      end
    end
  end
end
