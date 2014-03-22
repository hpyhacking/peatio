module Private
  module Deposits
    class BaseController < ::Private::BaseController
      before_action :auth_activated!
    end
  end
end
