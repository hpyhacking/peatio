module Test
  class ModuleController < ActionController::Base
    before_action { head :not_found if Rails.env.production? }
  end
end
