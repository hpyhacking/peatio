# encoding: UTF-8
# frozen_string_literal: true

module Private
  class OrderAsksController < BaseController
    include Concerns::OrderCreation

    def create
      @order = OrderAsk.new(order_params(:order_ask))
      order_submit
    end

    def clear
      @orders = OrderAsk.where(member_id: current_user.id).with_state(:wait).with_market(current_market)
      Ordering.new(@orders).cancel
      render status: 200, nothing: true
    end

    def currency
      "#{params[:ask]}#{params[:bid]}".to_sym
    end

  end
end
