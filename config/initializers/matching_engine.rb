# encoding: UTF-8
# frozen_string_literal: true

case ENV.fetch('MATCHING_ENGINE', 'peatio')
when 'finex'
  Rails.logger.info { 'Use finex as third-party matching engine' }
  Order::TYPES << 'post_only'
when 'peatio'
  Rails.logger.info { 'Use default matching engine' }
end
Order::TYPES.freeze
Order.enumerize :ord_type, in: Order::TYPES, scope: true
