module API
  module V1
    class BaseController < ::ApplicationController
      skip_before_filter :set_language, :setting_default
    end
  end
end

