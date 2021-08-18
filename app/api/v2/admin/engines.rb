# frozen_string_literal: true

module API
  module V2
    module Admin
      class Engines < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all engine, result is paginated.',
             is_array: true,
             success: API::V2::Admin::Entities::Engine
        params do
          use :pagination
          use :ordering
        end
        get '/engines' do
          admin_authorize! :read, ::Engine

          result = ::Engine.order(params[:order_by] => params[:ordering])
          present paginate(result), with: API::V2::Admin::Entities::Engine
        end

        desc 'Get engine.' do
          success API::V2::Admin::Entities::Engine
        end
        params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:id][:desc] }
        end
        get '/engines/:id' do
          admin_authorize! :read, ::Engine

          present ::Engine.find(params[:id]), with: API::V2::Admin::Entities::Engine
        end

        desc 'Create new engine.' do
          success API::V2::Admin::Entities::Engine
        end
        params do
          requires :name,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:name][:desc] },
                   values: { value: ->(v) { !v.in?(::Engine.pluck(:name)) }, message: 'admin.engine.duplicate_name' }
          requires :driver,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:driver][:desc] }
          optional :uid,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:uid][:desc] }
          optional :url,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:url][:desc] }
          optional :key,
                   desc: -> { 'Credentials for remote engine' }
          optional :secret,
                   desc: -> { 'Credentials for remote engine' }
          optional :state,
                   type: { value: Integer, message: 'admin.engine.non_integer_state' },
                   values: { value: ::Engine::STATES.values, message: 'admin.engine.invalid_state' },
                   default: Engine::STATES[:online],
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:state][:desc] }
          optional :data,
                   desc: -> { 'Metadata for engine' }
        end
        post '/engines/new' do
          admin_authorize! :create, ::Engine

          engine = ::Engine.new(declared(params))
          if engine.save
            present engine, with: API::V2::Admin::Entities::Engine
            status 201
          else
            body errors: engine.errors.full_messages
            status 422
          end
        end

        desc 'Update engine' do
          success API::V2::Admin::Entities::Engine
        end
        params do
          requires :id,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:id][:desc] }
          optional :name,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:name][:desc] }
          optional :driver,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:driver][:desc] }
          optional :url,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:url][:desc] }
          optional :uid,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:uid][:desc] }
          optional :key,
                   desc: -> { 'Credentials for remote engine' }
          optional :secret,
                   desc: -> { 'Credentials for remote engine' }
          optional :state,
                   values: { value: ::Engine::STATES.values, message: 'admin.engine.invalid_state' },
                   default: 1,
                   desc: -> { API::V2::Admin::Entities::Engine.documentation[:state][:desc] }
        end
        post '/engines/update' do
          admin_authorize! :update, ::Engine

          engine = ::Engine.find(params[:id])
          if engine.update(declared(params, include_missing: false))
            present engine, with: API::V2::Admin::Entities::Engine
          else
            body errors: engine.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
