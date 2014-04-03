module APIv2
  module Helpers

    def authenticate!
      unless Authenticator.new(request, params).authentic?
        throw :error, status: 401, message: "API Authorization Failed."
      end
    end

    def current_user
      @current_user ||= Member.find_by_email('foo@peatio.dev')
    end

  end
end
