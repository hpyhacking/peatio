# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Helpers
        extend ::Grape::API::Helpers

        class RansackBuilder
          # RansackBuilder creates a hash in a format ransack accepts
          # eq(:column) generetes a pair column_eq: params[:column]
          # translate(:column1 => :column2) generates a pair column2_eq: params[:column1]
          # merge allows to append additional selectors in
          # build returns prepared hash

          attr_reader :build

          def initialize(params)
            @params = params
            @build = {}
          end

          def merge(opt)
            @build.merge!(opt)
            self
          end

          def with_daterange
            @build.merge!("#{@params[:range]}_at_gteq" => @params[:from])
            @build.merge!("#{@params[:range]}_at_lteq" => @params[:to])
            self
          end

          def translate(opt)
            opt.each { |k, v| @build.merge!("#{v}_eq" => @params[k]) }
            self
          end

          def translate_in(opt)
            opt.each { |k, v| @build.merge!("#{v}_in" => @params[k]) }
            self
          end

          def in(*keys)
            keys.each { |k| @build.merge!("#{k}_in" => @params[k]) }
            self
          end

          def eq(*keys)
            keys.each { |k| @build.merge!("#{k}_eq" => @params[k]) }
            self
          end
        end

        params :currency_type do
          optional :type,
                   type: String,
                   values: { value: ::Currency.types.map(&:to_s), message: 'admin.currency.invalid_type' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:type][:desc] }
        end

        params :currency do
          optional :currency,
                   values: { value: -> { Currency.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:currency][:desc] }
        end

        params :uid do
          optional :uid,
                   values:  { value: -> (v) { Member.exists?(uid: v) }, message: 'admin.user.doesnt_exist' },
                   desc: -> { API::V2::Entities::Member.documentation[:uid][:desc] }
        end

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

        params :ordering do
          optional :ordering,
                   values: { value: %w(asc desc), message: 'admin.pagination.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   desc: 'Name of the field, which result will be ordered by.'
        end

        params :date_picker do
          optional :range,
                   default: 'created',
                   values: { value: -> { %w[created updated completed] } },
                   desc: 'Date range picker, defaults to \'created\'.'
          optional :from,
                   type: { value: Time, message: 'admin.filter.range_from_invalid' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities FROM the time will be retrieved.'
          optional :to,
                   type: { value: Time, message: 'admin.filter.range_to_invalid' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities BEFORE the time will be retrieved.'
        end
      end
    end
  end
end
