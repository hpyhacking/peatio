# encoding: UTF-8
# frozen_string_literal: true

module Matching
  # TODO: doc.
  class BaseOrder

    attr_reader :id, :timestamp, :type, :market, :volume

    def initialize(attrs)
      @id         = attrs[:id]
      @timestamp  = attrs[:timestamp]
      @type       = attrs[:type].to_sym
      @volume     = attrs[:volume].to_d
      @market     = attrs[:market]
    end

    def trade_with(_counter_order, _counter_book)
      method_not_implemented
    end

    def fill(_trade_price, _trade_volume, _trade_funds)
      method_not_implemented
    end

    def filled?
      method_not_implemented
    end

    def label
      method_not_implemented
    end

    def valid?(_attrs)
      method_not_implemented
    end

    def attributes
      method_not_implemented
    end

    def bid?
      @type == :bid
    end

    def ask?
      @type == :ask
    end
  end
end
