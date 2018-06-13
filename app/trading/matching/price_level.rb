# encoding: UTF-8
# frozen_string_literal: true

module Matching
  class PriceLevel

    attr :price, :orders

    def initialize(price)
      @price  = price
      @orders = []
    end

    def top
      @orders.first
    end

    def empty?
      @orders.empty?
    end

    def add(order)
      unless find(order.id)
        @orders << order
      end
    end

    def remove(order)
      @orders.delete_if { |o| o.id == order.id }
    end

    def find(id)
      @orders.find { |o| o.id == id }
    end
  end
end
