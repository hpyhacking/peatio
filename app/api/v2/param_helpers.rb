# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module ParamHelpers
      extend ::Grape::API::Helpers

      params :pagination do
        optional :limit,
                 type: { value: Integer, message: 'pagination.non_integer_limit' },
                 values: { value: 1..1000, message: 'pagination.invalid_limit' },
                 default: 100,
                 desc: 'Limit the number of returned paginations. Defaults to 100.'
        optional :page,
                 type: { value: Integer, message: 'pagination.non_integer_page' },
                 allow_blank: false,
                 default: 1,
                 desc: 'Specify the page of paginated results.'
      end

      params :ordering do
        optional :ordering,
                 values: { value: %w(asc desc), message: 'pagination.invalid_ordering' },
                 default: 'asc',
                 desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
        optional :order_by,
                 default: 'id',
                 desc: 'Name of the field, which result will be ordered by.'
      end
    end
  end
end
