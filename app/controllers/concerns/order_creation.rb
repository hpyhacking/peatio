# encoding: UTF-8
# frozen_string_literal: true

module Concerns
  module OrderCreation
    extend ActiveSupport::Concern

    def order_params(order)
      params[order][:bid] = Currency.enabled.find(params[:bid])&.id
      params[order][:ask] = Currency.enabled.find(params[:ask])&.id
      params[order][:state] = Order::WAIT
      params[order][:market_id] = params[:market]
      params[order][:member_id] = current_user.id
      params[order][:volume] = params[order][:origin_volume]
      params.require(order).permit(
        :bid, :ask, :market_id, :price,
        :state, :origin_volume, :volume, :member_id, :ord_type)
    end

    def order_submit
      begin
        Ordering.new(@order).submit
        render status: 200, json: success_result
      rescue => e
        Rails.logger.error { "Member id=#{current_user.id} failed to submit order." }
        Rails.logger.debug { params.inspect }
        report_exception(e)
        render status: 500, json: error_result(@order.errors)
      end
    end

    def success_result
      Jbuilder.encode do |json|
        json.result true
        json.message I18n.t("private.markets.show.success")
      end
    end

    def error_result(args)
      Jbuilder.encode do |json|
        json.result false
        json.message I18n.t("private.markets.show.error")
        json.errors args
      end
    end
  end
end
