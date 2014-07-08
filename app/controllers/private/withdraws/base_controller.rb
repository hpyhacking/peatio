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

      def two_factor_activated!
        if not current_user.two_factors.activated?
          redirect_to settings_path, alert: t('private.two_factors.auth.please_active_two_factor')
        end
      end

    end
  end
end
