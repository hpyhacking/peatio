module APIv2
  module Helpers

    def authenticate!
      auth = Authenticator.new(request, @raw_params)
      if auth.authentic?
        @current_user = auth.token.member
      else
        raise AuthorizationError
      end
    end

    def current_user
      @current_user
    end

    def current_market
      @current_market ||= Market.find params[:market]
    end
  end
end
