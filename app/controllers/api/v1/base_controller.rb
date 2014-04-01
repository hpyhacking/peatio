module Api
  module V1
    class BaseController < ::ApplicationController
      skip_before_filter :setting_default
    end
  end
end

