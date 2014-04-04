module APIv2
  module Helpers

    def authenticate!
      auth = Authenticator.new(request, params)
      if auth.authentic?
        @current_user = auth.token.member
      else
        throw :error, status: 401, message: "API Authorization Failed."
      end
    end

    def current_user
      @current_user
    end

  end
end
