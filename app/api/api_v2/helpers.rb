module APIv2
  module Helpers

    def current_user
      @current_user ||= Member.find_by_email('foo@peatio.dev')
    end

  end
end
