# encoding: UTF-8
# frozen_string_literal: true

module Private
  class BaseController < ::ApplicationController
    before_filter :no_cache, :auth_member!

    private

    def deposits_must_be_permitted!
      if current_user.level < ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_DEPOSIT').to_i
        redirect_to settings_path, alert: t('private.settings.index.deposits_must_be_permitted')
      end
    end

    def withdraws_must_be_permitted!
      if current_user.level < ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_WITHDRAW').to_i
        redirect_to settings_path, alert: t('private.settings.index.withdraws_must_be_permitted')
      end
    end

    def trading_must_be_permitted!
      if current_user.level < ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_TRADING').to_i
        redirect_to settings_path, alert: t('private.settings.index.trading_must_be_permitted')
      end
    end

    def no_cache
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Sat, 03 Jan 2009 00:00:00 GMT"
    end
  end
end
