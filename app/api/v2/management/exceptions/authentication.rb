# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Exceptions
        class Authentication < Base
          def status
            @options.fetch(:status, 401)
          end
        end
      end
    end
  end
end
