class Ordering
  PRICE_RANGE = ("0.01".to_d.."100".to_d)
  class LatestPriceError < RuntimeError; end
  class CancelOrderError < StandardError; end

  def initialize(order)
    @order = order
  end

  def member
    @member ||= Member.find(@order.member_id)
  end

  def submit
    check_price!

    ActiveRecord::Base.transaction do
      @order.fix_number_precision # number must be fixed before computing locked
      @order.locked = @order.origin_locked = @order.compute_locked
      @order.save!

      account = @order.hold_account
      account.lock_funds(@order.locked, reason: Account::ORDER_SUBMIT, ref: @order)

    end

    AMQPQueue.enqueue(:matching, action: 'submit', order: @order.to_matching_attributes)

    true
  end

  def cancel
    AMQPQueue.enqueue(:matching, action: 'cancel', order: @order.to_matching_attributes)
  end

  def cancel!
    ActiveRecord::Base.transaction do
      order = Order.find(@order.id).lock!
      account = @order.hold_account

      if order.state == Order::WAIT
        order.state = Order::CANCEL
        account.unlock_funds(order.locked, reason: Account::ORDER_CANCEL, ref: order)
        order.save!
      else
        raise CancelOrderError, "Only active order can be cancelled. id: #{order.id}, state: #{order.state}"
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
