# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Operations < Grape::API

        # POST: api/v2/management/assets
        # POST: api/v2/management/expenses
        # POST: api/v2/management/revenues
        #
        # POST: api/v2/management/assets/new
        # POST: api/v2/management/expenses/new
        # POST: api/v2/management/revenues/new
        ::Operations::Account::PLATFORM_TYPES.each do |op_type|
          op_type_plural = op_type.to_s.pluralize

          desc "Returns #{op_type_plural} as paginated collection." do
            @settings[:scope] = :read_operations
            success API::V2::Management::Entities::Operation
          end
          params do
            optional :currency,
                     type: String,
                     values: -> { Currency.codes(bothcase: true) },
                     desc: 'The currency for operations filtering.'
            optional :page,
                     type: Integer, default: 1,
                     integer_gt_zero: true,
                     desc: 'The page number (defaults to 1).'
            optional :limit,
                     type: Integer,
                     default: 100,
                     range: 1..1000,
                     desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
            optional :time_from,
                    type: Integer,
                    desc: "An integer represents the seconds elapsed since Unix epoch."\
                        "If set, only operations after the time will be returned."
            optional :time_to,
                    type: Integer,
                    desc: "An integer represents the seconds elapsed since Unix epoch."\
                       "If set, only operations before the time will be returned."
            optional :reference_type,
                    type: String,
                    desc: "The reference type for operations filtering"
          end
          post op_type_plural do
            currency_id = params.fetch(:currency, nil)

            "operations/#{op_type}"
              .camelize
              .constantize
              .order(id: :desc)
              .tap { |q| q.where!(currency_id: currency_id) if currency_id }
              .tap { |q| q.where!(reference_type: params[:reference_type]) if params[:reference_type].present? }
              .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from].present? }
              .tap { |q| q.where!('created_at < ?', Time.at(params[:time_to])) if params[:time_to].present? }
              .page(params[:page])
              .per(params[:limit])
              .tap { |q| present q, with: API::V2::Management::Entities::Operation }
            status 200
          end

          desc "Creates new #{op_type} operation." do
            @settings[:scope] = :write_operations
            success API::V2::Management::Entities::Operation
          end
          params do
            requires :currency,
                     type: String,
                     values: -> { ::Currency.codes(bothcase: true) },
                     desc: 'The currency code.'
            requires :code,
                     type: Integer,
                     values: -> { ::Operations::Account.where(type: op_type).pluck(:code) },
                     desc: 'Operation account code'
            optional :debit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation debit amount.'
            optional :credit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation credit amount.'
            exactly_one_of :debit, :credit
          end
          post "/#{op_type_plural}/new" do
            attributes = declared(params)

            create_operation!(attributes).tap do |op|
              present op, with: Entities::Operation
            end
            status 200
          rescue ActiveRecord::RecordInvalid => e
            body errors: e.message
            status 422
          end
        end

        # POST: api/v2/management/liabilities
        #
        # POST: api/v2/management/liabilities/new
        ::Operations::Account::MEMBER_TYPES.each do |op_type|
          op_type_plural = op_type.to_s.pluralize

          desc "Returns #{op_type_plural} as paginated collection." do
            @settings[:scope] = :read_operations
            success API::V2::Management::Entities::Operation
          end
          params do
            optional :currency,
                     type: String,
                     values: -> { Currency.codes(bothcase: true) },
                     desc: 'The currency for operations filtering.'
            optional :uid,
                     type: String,
                     desc: 'The user ID for operations filtering.'
            optional :reference_type,
                     type: String,
                     desc: "The reference type for operations filtering"
            optional :time_from,
                     type: Integer,
                     desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only operations after the time will be returned."
            optional :time_to,
                     type: Integer,
                     desc: "An integer represents the seconds elapsed since Unix epoch."\
                        "If set, only operations before the time will be returned."
            optional :page,
                     type: Integer,
                     default: 1,
                     integer_gt_zero: true,
                     desc: 'The page number (defaults to 1).'
            optional :limit,
                     type: Integer,
                     default: 100,
                     range: 1..10000,
                     desc: 'The number of objects per page (defaults to 100, maximum is 10000).'
          end
          post op_type_plural do
            currency_id = params.fetch(:currency, nil)
            member = Member.find_by!(uid: params[:uid]) if params[:uid].present?

            "operations/#{op_type}"
              .camelize
              .constantize
              .order(id: :desc)
              .tap { |q| q.where!(currency_id: currency_id) if currency_id }
              .tap { |q| q.where!(member: member) if member }
              .tap { |q| q.where!(reference_type: params[:reference_type]) if params[:reference_type].present? }
              .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from].present? }
              .tap { |q| q.where!('created_at < ?', Time.at(params[:time_to])) if params[:time_to].present? }
              .tap { |q| present paginate(q), with: API::V2::Management::Entities::Operation }
            status 200
          end

          desc "Creates new #{op_type} operation." do
            @settings[:scope] = :write_operations
            success API::V2::Management::Entities::Operation
          end
          params do
            requires :currency,
                     type: String,
                     values: -> { ::Currency.codes(bothcase: true) },
                     desc: 'The currency code.'
            requires :code,
                     type: Integer,
                     values: -> { ::Operations::Account.where(type: op_type).pluck(:code) },
                     desc: 'Operation account code'
            given code: ->(code) { ::Operations::Account.find_by(code: code).try(:scope).try(:member?) } do
              requires :uid,
                       type: String,
                       desc: 'The user ID for operation owner.'
            end
            optional :debit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation debit amount.'
            optional :credit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation credit amount.'
            exactly_one_of :debit, :credit
          end
          post "/#{op_type_plural}/new" do
            attributes = declared(params)

            create_operation!(attributes).tap do |op|
              present op, with: Entities::Operation
            end
            status 200
          rescue ActiveRecord::RecordInvalid => e
            body errors: e.message
            status 422
          end
        end
      end
    end
  end
end
