module Private
  class BaseController < ::ApplicationController
    before_action :check_email_nil
    before_filter :no_cache, :auth_member!

    private

    def no_cache
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Sat, 03 Jan 2009 00:00:00 GMT"
    end

    def check_email_nil
      redirect_to new_authentications_email_path if current_user && current_user.email.nil?
    end

  end
end
