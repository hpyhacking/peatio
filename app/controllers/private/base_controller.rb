module Private
  class BaseController < ::ApplicationController
    before_filter :auth_member!
  end
end
