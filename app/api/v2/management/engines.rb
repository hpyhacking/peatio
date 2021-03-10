# frozen_string_literal: true

module API
  module V2
    module Management
      class Engines < Grape::API
        namespace :engines do
          desc 'Get all engine, result is paginated.' do
            @settings[:scope] = :read_engines
            success API::V2::Management::Entities::Engine
          end
          params do
            optional :limit,
                     type: { value: Integer, message: 'management.pagination.non_integer_limit' },
                     values: { value: 1..1000, message: 'management.pagination.invalid_limit' },
                     default: 100,
                     desc: 'Limit the number of returned paginations. Defaults to 100.'
            optional :page,
                     type: { value: Integer, message: 'management.pagination.non_integer_page' },
                     allow_blank: false,
                     default: 1,
                     desc: 'Specify the page of paginated results.'
            optional :name,
                     type: String,
                     coerce_with: ->(c) { c.strip.downcase },
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:name][:desc] }
            optional :ordering,
                     values: { value: %w(asc desc), message: 'management.pagination.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
          end
          post '/get' do
            ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                               .eq(:name)
                               .build

            search = ::Engine.ransack(ransack_params)
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"

            present paginate(search.result), with: API::V2::Management::Entities::Engine
          end

          desc 'Creates new engine' do
            @settings[:scope] = :write_engines
            success API::V2::Management::Entities::Engine
          end
          params do
            requires :name,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:name][:desc] },
                     values: { value: ->(v) { !v.in?(::Engine.pluck(:name)) }, message: 'management.engine.duplicate_name' }
            requires :driver,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:driver][:desc] }
            optional :uid,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:uid][:desc] }
            optional :url,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:url][:desc] }
            optional :state,
                     values: { value: ::Engine::STATES.values, message: 'management.engine.invalid_state' },
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:state][:desc] }
            optional :key,
                     desc: -> { 'Credentials for remote engine' }
            optional :secret,
                     desc: -> { 'Credentials for remote engine' }
            optional :data,
                     desc: -> { 'Metadata for engine' }
          end
          post '/new' do
            engine = ::Engine.new(declared(params, include_missing: false))
            if engine.save
              present engine, with: API::V2::Management::Entities::Engine
              status 201
            else
              body errors: engine.errors.full_messages
              status 422
            end
          end

          desc 'Update engine' do
            @settings[:scope] = :write_engines
            success API::V2::Management::Entities::Engine
          end
          params do
            requires :id,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:id][:desc] }
            optional :uid,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:uid][:desc] }
            optional :name,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:name][:desc] }
            optional :driver,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:driver][:desc] }
            optional :url,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:url][:desc] }
            optional :key,
                     desc: -> { 'Credentials for remote engine' }
            optional :secret,
                     desc: -> { 'Credentials for remote engine' }
            optional :state,
                     values: { value: ::Engine::STATES.values, message: 'management.engine.invalid_state' },
                     default: 1,
                     desc: -> { API::V2::Management::Entities::Engine.documentation[:state][:desc] }
          end
          post '/update' do
            engine = ::Engine.find(params[:id])
            if engine.update(declared(params, include_missing: false))
              present engine, with: API::V2::Management::Entities::Engine
            else
              body errors: engine.errors.full_messages
              status 422
            end
          end
        end
      end
    end
  end
end
