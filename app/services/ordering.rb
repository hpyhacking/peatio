class Ordering
  PRICE_RANGE = ("0.01".to_d.."100".to_d)
  class LatestPriceError < RuntimeError; end
  class CancelOrderError < StandardError; end

  def initialize(order_or_orders)
    @orders = Array(order_or_orders)
  end

  def submit
    ActiveRecord::Base.transaction do
      @orders.each {|order| do_submit order }
    end

    @orders.each do |order|
      AMQPQueue.enqueue(:matching, action: 'submit', order: order.to_matching_attributes)
    end

    true
  end

  def cancel
    @orders.each {|order| do_cancel order }
  end

  def cancel!
    ActiveRecord::Base.transaction do
      @orders.each {|order| do_cancel! order }
    end
  end

  private

  def check_price!(order)
    if order.ord_type == 'limit' && !price_in_range?(order)
      order.errors.add(:price, :range)
      raise LatestPriceError, "invalid price"
    end
  end

  def price_in_range?(order)
    latest = Trade.latest_price(order.currency)
    latest.zero? || PRICE_RANGE.cover?(order.price / latest)
  end

  def do_submit(order)
    check_price!(order)

    order.fix_number_precision # number must be fixed before computing locked
    order.locked = order.origin_locked = order.compute_locked
    order.save!

    account = order.hold_account
    account.lock_funds(order.locked, reason: Account::ORDER_SUBMIT, ref: order)
  end

  def do_cancel(order)
    AMQPQueue.enqueue(:matching, action: 'cancel', order: order.to_matching_attributes)
  end

  def do_cancel!(order)
    account = order.hold_account
    order   = Order.find(order.id).lock!

    if order.state == Order::WAIT
      order.state = Order::CANCEL
      account.unlock_funds(order.locked, reason: Account::ORDER_CANCEL, ref: order)
      order.save!
    else
      raise CancelOrderError, "Only active order can be cancelled. id: #{order.id}, state: #{order.state}"
    end
  end

end
