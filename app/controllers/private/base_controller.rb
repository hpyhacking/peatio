module Private
  class BaseController < ::ApplicationController
    before_filter :auth_member!
    before_filter :auth_active!

    def channel
      "private-#{current_user.sn}"
    end
  end
end
