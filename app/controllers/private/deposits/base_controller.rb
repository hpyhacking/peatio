module Private
  module Deposits
    class BaseController < ::Private::BaseController
      before_action :fetch_channel
      before_action :auth_activated!

      def fetch_channel
        @channel ||= "deposit_channel_#{controller_name}".classify.constantize.get
        @currency ||= @channel.currency
      end
    end
  end
end

