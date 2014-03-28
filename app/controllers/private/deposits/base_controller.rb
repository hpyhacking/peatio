module Private
  module Deposits
    class BaseController < ::Private::BaseController
      before_action :featch_channel!
      before_action :auth_activated!

      def featch_channel!
        @channel = DepositChannel.find_by_key(self.controller_name.singularize)
        @currency = currency
      end
    end
  end
end

