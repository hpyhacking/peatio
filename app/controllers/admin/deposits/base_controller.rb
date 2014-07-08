module Admin
  module Deposits
    class BaseController < ::Admin::BaseController
      def channel
        @channel ||= DepositChannel.find_by_key(self.controller_name.singularize)
      end

      def kls
        channel.kls
      end
    end
  end
end
