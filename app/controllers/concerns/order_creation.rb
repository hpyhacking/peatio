module Concerns
  module OrderCreation
    extend ActiveSupport::Concern

    def order_params(order)
      params[order][:bid] = params[:bid]
      params[order][:ask] = params[:ask]
      params[order][:state] = Order::WAIT
      params[order][:currency] = params[:market]
      params[order][:member_id] = current_user.id
      params[order][:volume] = params[order][:origin_volume]
      params[order][:source] = 'Web'
      params.require(order).permit(
        :bid, :ask, :currency, :price, :source,
        :state, :origin_volume, :volume, :member_id, :ord_type)
    end

    def order_submit
      begin
        Ordering.new(@order).submit
        render status: 200, json: success_result
      rescue
        Rails.logger.warn "Member id=#{current_user.id} failed to submit order: #{$!}"
        Rails.logger.warn params.inspect
        Rails.logger.warn $!.backtrace[0,20].join("\n")
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
