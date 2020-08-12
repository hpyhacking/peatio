# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Operations < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          params :get_operations_params do
            optional :reference_type,
                     desc: 'The reference type for which operation was created.'
            optional :rid,
                     type: Integer,
                     desc: 'The unique id of operation\'s reference, for which operation was created.'
            optional :code,
                     type: Integer,
                     desc: 'Opeartion\'s code.'
            use :currency
            use :date_picker
          end

          def ransack_params
            Helpers::RansackBuilder.new(params)
              .eq(:code, :reference_type)
              .translate(currency: :currency_id, rid: :reference_id)
              .with_daterange
              .build
          end
        end

        # GET: api/v2/admin/assets
        # GET: api/v2/admin/expenses
        # GET: api/v2/admin/revenues
        ::Operations::Account::PLATFORM_TYPES.each do |op_type|
          op_type_plural = op_type.to_s.pluralize

          desc "Returns #{op_type_plural} as a paginated collection." do
            success API::V2::Admin::Entities::Operation
          end
          params do
            use :get_operations_params
            use :pagination
            use :ordering
          end
          get op_type_plural do
            klass = ::Operations.const_get(op_type.capitalize)
            admin_authorize! :read, klass

            search = klass.ransack(ransack_params)
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"

            present paginate(search.result, false), with: API::V2::Admin::Entities::Operation
          end
        end

        # Get: api/v2/admin/liabilities
        ::Operations::Account::MEMBER_TYPES.each do |op_type|
          op_type_plural = op_type.to_s.pluralize

          desc "Returns #{op_type_plural} as a paginated collection." do
            success API::V2::Admin::Entities::Operation
          end
          params do
            use :uid
            use :get_operations_params
            use :pagination
            use :ordering
          end
          get op_type_plural do
            klass = ::Operations.const_get(op_type.capitalize)
            admin_authorize! :read, klass

            member = Member.find_by(uid: params[:uid]) if params[:uid].present?
            search = klass.ransack(ransack_params.merge(member_id_eq: member&.id))
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"

            present paginate(search.result, false), with: API::V2::Admin::Entities::Operation
          end
        end
      end
    end
  end
end
