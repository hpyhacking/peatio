class Ordering
  PRICE_RANGE = ("0.01".to_d.."100".to_d)
  class LatestPriceError < RuntimeError; end

  def initialize(order)
    @order = order
  end

  def member
    @member ||= Member.find(@order.member_id)
  end

  def submit
    check_price!

    ActiveRecord::Base.transaction do
      @order.locked = @order.origin_locked = @order.compute_locked
      @order.save!

      account = @order.hold_account.lock!
      account.lock_funds(@order.locked, reason: Account::ORDER_SUBMIT, ref: @order)

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
        account.unlock_funds(order.compute_locked, reason: Account::ORDER_CANCEL, ref: order)
        order.save!

        AMQPQueue.enqueue(:matching, action: 'cancel', order: @order.to_matching_attributes)
        true
      else
        false
      end
    end
  end

  private

  def check_price!
    if @order.ord_type == 'limit' && !price_in_range?
      @order.errors.add(:price, :range)
      raise LatestPriceError, "invalid price"
    end
  end

  def price_in_range?
    latest = Trade.latest_price(@order.currency)
    latest.zero? || PRICE_RANGE.cover?(@order.price / latest)
  end

end
