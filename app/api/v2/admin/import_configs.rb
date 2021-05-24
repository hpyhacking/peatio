# frozen_string_literal: true

module API
  module V2
    module Admin
      class ImportConfigs < Grape::API

        desc 'Import currencies, blockchains and wallets from json/yaml file'
        params do
          requires :file,
                   type: File,
                   desc: 'File which consists of wallets/currencies/blockchains configurations'
        end
        post '/import_configs' do
          API::V2::ImportConfigsHelper.new.process(params[:file])
        end
      end
    end
  end
end
