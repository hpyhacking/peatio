module Private
  module Withdraws
    class BaseController < ::Private::BaseController
      before_action :channel
      before_action :auth_activated!
      before_action :auth_verified!
      before_action :two_factor_activated!

      def channel
        @channel ||= WithdrawChannel.find_by_key(self.controller_name.singularize)
      end

      def model_kls
        "withdraws/#{self.controller_name.singularize}".camelize.constantize
      end

    end
  end
end
