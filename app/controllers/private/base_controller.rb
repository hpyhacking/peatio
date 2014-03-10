module Private
  class BaseController < ::ApplicationController
    before_filter :auth_member!

    def channel
      "private-#{current_user.sn}"
    end
  end
end
