module Admin
  module Withdraws
    class BaseController < ::Admin::BaseController
      def channel
        @channel ||= WithdrawChannel.find_by_key(self.controller_name.singularize)
      end

      def kls
        channel.kls
      end

    protected

      def find_withdraw
        @withdraw = channel.kls.find(params[:id])
      end
    end
  end
end
