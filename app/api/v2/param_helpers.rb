# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module ParamHelpers
      extend ::Grape::API::Helpers

      params :pagination do
        optional :limit,
                 type: { value: Integer, message: 'admin.pagination.non_integer_limit' },
                 values: { value: 1..1000, message: 'admin.pagination.invalid_limit' },
                 default: 100,
                 desc: 'Limit the number of returned paginations. Defaults to 100.'
        optional :page,
                 type: { value: Integer, message: 'admin.pagination.non_integer_page' },
                 allow_blank: false,
                 default: 1,
                 desc: 'Specify the page of paginated results.'
      end
    end
  end
end
