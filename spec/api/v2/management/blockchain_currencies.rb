# frozen_string_literal: true

describe API::V2::Management::BlockchainCurrencies, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_blockchain_currencies: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_blockchain_currencies: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  describe 'POST blockchain_currencies/list' do
    def request
      post_json '/api/v2/management/blockchain_currencies/list', multisig_jwt_management_api_v1({ data: blockchain_currency_data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:blockchain_currency_data) do
      {
      }
    end

    it 'list of blockchain currencies' do
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.count
    end

    it 'list of deposit enabled blockchain currencies' do
      blockchain_currency_data.merge!(deposit_enabled: true)
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.deposit_enabled.count
    end

    it 'list of deposit disabled blockchain currencies' do
      blockchain_currency_data.merge!(deposit_enabled: false)
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(deposit_enabled: false).count
    end

    it 'returns error in case of invalid deposit_enabled type' do
      blockchain_currency_data.merge!(deposit_enabled: 'invalid' )
      request
      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_boolean_deposit_enabled/i)
    end

    it 'list of withdrawal enabled blockchain currencies' do
      blockchain_currency_data.merge!(withdrawal_enabled: true )
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.withdrawal_enabled.count
    end

    it 'list of withdrawal disabled blockchain currencies' do
      blockchain_currency_data.merge!(withdrawal_enabled: false )
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(withdrawal_enabled: false).count
    end

    it 'returns error in case of invalid withdrawal_enabled type' do
      blockchain_currency_data.merge!(withdrawal_enabled: 'invalid')
      request
      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_boolean_withdrawal_enabled/i)
    end

    it 'list of enabled blockchain currencies' do
      blockchain_currency_data.merge!(status: :enabled)
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(status: :enabled).count
    end

    it 'list of disabled blockchain currencies' do
      blockchain_currency_data.merge!(status: :disabled)
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(status: :disabled).count
    end

    it 'returns error in case of invalid status type' do
      blockchain_currency_data.merge!(status: 'invalid')
      request
      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.invalid_status/i)
    end

    it 'returns blockchain currencies by ascending order' do
      blockchain_currency_data.merge!(ordering: 'asc', order_by: 'currency_id')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['currency_id']).to eq 'btc'
    end

    it 'returns paginated blockchain currencies' do
      blockchain_currency_data.merge!(limit: 3, page: 1)
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['currency_id']).to eq 'ring'

      blockchain_currency_data.merge!(limit: 3, page: 2)
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['currency_id']).to eq 'btc'
    end
  end

  describe 'POST blockchain_currencies/:id' do
    def request
      post_json "/api/v2/management/blockchain_currencies/#{blockchain_currency.id}", multisig_jwt_management_api_v1({}, *signers)
    end

    let(:signers) { %i[alex jeff] }

    let(:blockchain_currency) { BlockchainCurrency.find_by(blockchain_key: 'eth-rinkeby') }

    it 'returns information about specified blockchain currency' do
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result['id']).to eq blockchain_currency.id
      expect(result['deposit_enabled']).to eq blockchain_currency.deposit_enabled
      expect(result['withdrawal_enabled']).to eq blockchain_currency.withdrawal_enabled
      expect(result['deposit_fee']).to eq blockchain_currency.deposit_fee.to_s
      expect(result['min_deposit_amount']).to eq blockchain_currency.min_deposit_amount.to_s
      expect(result['withdraw_fee']).to eq blockchain_currency.withdraw_fee.to_s
      expect(result['min_withdraw_amount']).to eq blockchain_currency.min_withdraw_amount.to_s
      expect(result['base_factor']).to eq blockchain_currency.base_factor
      expect(result['status']).to eq blockchain_currency.status
      expect(result['min_collection_amount']).to eq blockchain_currency.min_collection_amount.to_s
      expect(result['options']).to eq blockchain_currency.options
      expect(result['currency_id']).to eq blockchain_currency.currency_id
      expect(result['blockchain_key']).to eq blockchain_currency.blockchain_key
    end
  end

  describe 'POST blockchain_currencies/new' do
    def request
      post_json '/api/v2/management/blockchain_currencies/new', multisig_jwt_management_api_v1({ data: blockchain_currency_data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:blockchain_currency_data) do
      {
      }
    end

    it 'create blockchain currency' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currency_id']).to eq 'eth'
      expect(result['blockchain_key']).to eq 'btc-testnet'
    end

    it 'create blockchain currency with parent' do
      blockchain_currency_data.merge!(currency_id: 'trst', blockchain_key: 'btc-testnet', parent_id: 'eth')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currency_id']).to eq 'trst'
      expect(result['parent_id']).to eq 'eth'
      expect(result['blockchain_key']).to eq 'btc-testnet'
    end

    it 'validate parent_id param' do
      blockchain_currency_data.merge!(currency_id: 'trst', blockchain_key: 'btc-testnet', parent_id: 'eur')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.parent_id_doesnt_exist/i)
    end

    it 'validate blockchain_key param' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'test')
      request
      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.blockchain_key_doesnt_exist/i)
    end

    it 'validate visible param' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', status: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.invalid_status/i)
    end

    it 'validate deposit_enabled param' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', deposit_enabled: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_boolean_deposit_enabled/i)
    end

    it 'validate withdrawal_enabled param' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', withdrawal_enabled: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_boolean_withdrawal_enabled/i)
    end

    it 'validate options param' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', options: 'test')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_json_options/i)
    end

    it 'verifies subunits >= 0' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: -1)
      request

      expect(response.body).to match(/management.blockchain_currency.invalid_subunits/i)
      expect(response).not_to be_successful
    end

    it 'verifies subunits <= 18' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: 19)
      request

      expect(response.body).to match(/management.blockchain_currency.invalid_subunits/i)
      expect(response).not_to be_successful
    end

    it 'creates 1_000_000_000_000_000_000 base_factor' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: 18)
      request

      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['base_factor']).to eq 1_000_000_000_000_000_000
      expect(result['subunits']).to eq 18
    end

    it 'return error while putting base_factor and subunit params' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: 18, base_factor: 1)
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.blockchain_currency.one_of_base_factor_subunits_fields/i)
    end

    it 'creates currency with 1000 base_factor' do
      blockchain_currency_data.merge!(currency_id: 'eth', blockchain_key: 'btc-testnet', base_factor: 1000)
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['base_factor']).to eq 1000
      expect(result['subunits']).to eq 3
    end

    it 'checked required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/currency_id is missing/i)
    end
  end

  describe 'POST blockchain_currencies/update' do
    def request
      post_json '/api/v2/management/blockchain_currencies/update', multisig_jwt_management_api_v1({ data: blockchain_currency_data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:blockchain_currency_data) do
      {
      }
    end

    it 'validate status param' do
      blockchain_currency_data.merge!(id: BlockchainCurrency.first.id, status: 'test')
      request
      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.invalid_status/i)
    end

    it 'validate deposit_enabled param' do
      blockchain_currency_data.merge!(id: BlockchainCurrency.first.id, deposit_enabled: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_boolean_deposit_enabled/i)
    end

    it 'validate withdrawal_enabled param' do
      blockchain_currency_data.merge!(id: BlockchainCurrency.first.id, withdrawal_enabled: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_boolean_withdrawal_enabled/i)
    end

    it 'validate options param' do
      blockchain_currency_data.merge!(id: BlockchainCurrency.first.id, options: 'test')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.blockchain_currency.non_json_options/i)
    end

    it 'checked required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/id is missing/i)
    end
  end
end
