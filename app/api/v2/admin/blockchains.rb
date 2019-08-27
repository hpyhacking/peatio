# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Blockchains < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all blockchains, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Blockchain
        params do
          use :pagination
          use :ordering
        end
        get '/blockchains' do
          authorize! :read, Blockchain

          result = Blockchain.order(params[:order_by] => params[:ordering])
          present paginate(result), with: API::V2::Admin::Entities::Blockchain
        end

        desc 'Get available blockchain clients.',
          is_array: true
        get '/blockchains/clients' do
          Blockchain.clients
        end

        desc 'Get a blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:id][:desc] }
        end
        get '/blockchains/:id' do
          authorize! :read, Blockchain

          present Blockchain.find(params[:id]), with: API::V2::Admin::Entities::Blockchain
        end

        desc 'Create new blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          requires :key,
                   values: { value: -> (v){ v && v.length < 255 }, message: 'admin.blockchain.key_too_long' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:key][:desc] }
          requires :name,
                   values: { value: -> (v){ v && v.length < 255 }, message: 'admin.blockchain.name_too_long' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:name][:desc] }
          requires :client,
                   values: { value: -> { ::Blockchain.clients.map(&:to_s) }, message: 'admin.blockchain.invalid_client' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:client][:desc] }
          requires :height,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_height' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_height' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:height][:desc] }
          optional :explorer_transaction,
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:explorer_transaction][:desc] }
          optional :explorer_address,
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:explorer_address][:desc] }
          optional :server,
                   regexp: { value: URI::regexp, message: 'admin.blockchain.invalid_server' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:server][:desc] }
          optional :status,
                   values: { value: %w(active disabled), message: 'admin.blockchain.invalid_status' },
                   default: 'active',
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:status][:desc] }
          optional :min_confirmations,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_min_confirmations' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_min_confirmations' },
                   default: 6,
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:min_confirmations][:desc] }
        end
        post '/blockchains/new' do
          authorize! :create, Blockchain

          blockchain = Blockchain.new(declared(params))
          if blockchain.save
            present blockchain, with: API::V2::Admin::Entities::Blockchain
            status 201
          else
            body errors: blockchain.errors.full_messages
            status 422
          end
        end

        desc 'Update blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:id][:desc] }
          optional :key,
                   values: { value: -> (v){ v.length < 255 }, message: 'admin.blockchain.key_too_long' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:key][:desc] }
          optional :name,
                   values: { value: -> (v){ v.length < 255 }, message: 'admin.blockchain.name_too_long' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:name][:desc] }
          optional :client,
                   values: { value: -> { ::Blockchain.clients.map(&:to_s) }, message: 'admin.blockchain.invalid_client' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:client][:desc] }
          optional :server,
                   regexp: { value: URI::regexp, message: 'admin.blockchain.invalid_server' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:server][:desc] }
          optional :height,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_height' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_height' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:height][:desc] }
          optional :explorer_transaction,
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:explorer_transaction][:desc] }
          optional :explorer_address,
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:explorer_address][:desc] }
          optional :status,
                   values: { value: %w(active disabled), message: 'admin.blockchain.invalid_status' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:status][:desc] }
          optional :min_confirmations,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_min_confirmations' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_min_confirmations' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:min_confirmations][:desc] }
        end
        post '/blockchains/update' do
          authorize! :write, Blockchain

          blockchain = Blockchain.find(params[:id])
          if blockchain.update(declared(params, include_missing: false))
            present blockchain, with: API::V2::Admin::Entities::Blockchain
          else
            body errors: blockchain.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
