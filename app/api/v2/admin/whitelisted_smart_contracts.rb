# frozen_string_literal: true

module API
  module V2
    module Admin
      class WhitelistedSmartContracts < Grape::API
        helpers ::API::V2::Admin::Helpers
        content_type :csv, 'text/csv'

        desc 'Get all whitelisted addresses, result is paginated.',
             is_array: true,
             success: API::V2::Admin::Entities::WhitelistedSmartContract
        params do
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.whitelistedsmartcontract.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:blockchain_key][:desc] }
          use :pagination
          use :ordering
        end
        get '/whitelisted_smart_contracts' do
          admin_authorize! :read, ::WhitelistedSmartContract

          ransack_params = Helpers::RansackBuilder.new(params).eq(:blockchain_key).build

          search = ::WhitelistedSmartContract.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          if params[:format] == 'csv'
            search.result
          else
            present paginate(search.result), with: API::V2::Admin::Entities::WhitelistedSmartContract
          end
        end

        desc 'Get a whitelisted address.' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.whitelistedsmartcontract.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:id][:desc] }
        end
        get '/whitelisted_smart_contract/:id' do
          admin_authorize! :read, ::WhitelistedSmartContract

          present ::WhitelistedSmartContract.find(params[:id]), with: API::V2::Admin::Entities::WhitelistedSmartContract
        end

        desc 'Creates new whitelisted address.' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.whitelistedsmartcontract.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:blockchain_key][:desc] }
          requires :address,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:address][:desc] }
          optional :description,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:description][:desc] }
          optional :state,
                   values: { value: %w[active disabled], message: 'admin.whitelistedsmartcontract.invalid_state' },
                   default: 'active',
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:state][:desc] }
        end
        post '/whitelisted_smart_contracts' do
          admin_authorize! :create, ::WhitelistedSmartContract

          whitelisted_address = ::WhitelistedSmartContract.new(declared(params))
          if whitelisted_address.save
            present whitelisted_address, with: API::V2::Admin::Entities::WhitelistedSmartContract
          else
            body errors: whitelisted_address.errors.full_messages
            status 422
          end
        end

        desc 'Update whitelisted_smart_contract.' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.whitelistedsmartcontract.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:id][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.whitelistedsmartcontract.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:blockchain_key][:desc] }
          optional :description,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:description][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:address][:desc] }
          optional :state,
                   values: { value: %w[active disabled], message: 'admin.whitelistedsmartcontract.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:state][:desc] }
        end
        put '/whitelisted_smart_contracts' do
          admin_authorize! :update, ::WhitelistedSmartContract
          whitelisted_address = ::WhitelistedSmartContract.find(params[:id])
          declared_params = declared(params, include_missing: false)

          if whitelisted_address.update(declared_params)
            present whitelisted_address, with: API::V2::Admin::Entities::WhitelistedSmartContract
          else
            body errors: whitelisted_address.errors.full_messages
            status 422
          end
        end

        desc 'Process whitelisted smart contracts from csv' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :file,
                   type: File,
                   desc: -> {'CSV file with whitelisted smart contracts data'}
        end
        post '/whitelisted_smart_contracts/csv' do
          admin_authorize! :create, ::WhitelistedSmartContract
          count = 0

          CSV.parse(params[:file][:tempfile], headers: true, quote_empty: false).each do |row|
            row = row.to_h.compact.symbolize_keys!
            address = row[:address]
            blockchain_key = row[:blockchain_key]
            description = row[:description]
            next if address.blank? || blockchain_key.blank? || ::Blockchain.pluck(:key).exclude?(blockchain_key)

            ::WhitelistedSmartContract.create!(description: description, address: address,
                                           blockchain_key: blockchain_key, state: 'active')
            count += 1
          end

          present ::WhitelistedSmartContract.last(count), with: API::V2::Admin::Entities::WhitelistedSmartContract
        end
      end
    end
  end
end
