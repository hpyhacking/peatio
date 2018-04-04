module ManagementAPIv1
  module Exceptions
    class Authentication < Base
      def status
        @options.fetch(:status, 401)
      end
    end
  end
end
