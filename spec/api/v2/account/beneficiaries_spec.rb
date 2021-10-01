# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::Beneficiaries, 'GET', type: :request do
  let(:endpoint) { '/api/v2/account/beneficiaries' }

  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  let!(:pending_beneficiaries_for_member) do
    create_list(:beneficiary, 2, member: member, state: :pending)
  end

  let!(:active_beneficiaries_for_member) do
    create_list(:beneficiary, 3, member: member, state: :active)
  end

  let!(:archived_beneficiaries_for_member) do
    create_list(:beneficiary, 2, member: member, state: :archived)
  end

  let!(:other_member_beneficiaries) do
    create_list(:beneficiary, 5)
  end

  def response_body
    JSON.parse(response.body)
  end

  before do
    Ability.stubs(:user_permissions).returns({'member'=>{'read'=>['Beneficiary'],'update'=>['Beneficiary'],
                                                         'create'=> ['Beneficiary'],'destroy'=> ['Beneficiary']}})
  end

  context 'without JWT' do
    it do
      get endpoint
      expect(response.status).to eq 401
    end
  end

  # TODO: Not enough level spec.
  # TODO: Paginate spec.

  context 'without currency and state' do
    it do
      api_get endpoint, token: token
      expect(response.status).to eq 200
      total_for_member = pending_beneficiaries_for_member.count + active_beneficiaries_for_member.count
      expect(response_body.size).to eq total_for_member
    end

    context 'pagination' do
      it 'should return paginated result' do
        api_get endpoint, token: token, params: { page: 1, limit: 1 }
        expect(response.status).to eq 200
        result = JSON.parse(response.body)
        expect(result.count).to eq 1

        api_get endpoint, token: token, params: { page: 2, limit: 1 }
        expect(response.status).to eq 200
        result = JSON.parse(response.body)
        expect(result.count).to eq 1
      end
    end
  end

  context 'non-existing currency' do
    it do
      api_get endpoint, params: { currency: :uah }, token: token
      expect(response.status).to eq 422
      expect(response).to include_api_error('account.currency.doesnt_exist')
    end
  end

  context 'existing currency' do
    let!(:btc_beneficiaries_for_member) do
      create_list(:beneficiary, 3, member: member)
    end

    it do
      api_get endpoint, params: { currency: :btc }, token: token
      expect(response.status).to eq 200
      expect(response_body.all? { |b| b['currency'] == 'btc' }).to be_truthy
    end
  end

  context 'invalid state' do
    it do
      api_get endpoint, params: { state: :invalid }, token: token
      expect(response.status).to eq 422
      expect(response).to include_api_error('account.beneficiary.invalid_state')
    end
  end

  context 'existing state' do
    it do
      api_get endpoint, params: { state: :pending }, token: token
      expect(response.status).to eq 200
      expect(response_body.all? { |b| b['state'] == 'pending' }).to be_truthy
    end
  end

  context 'multiple states' do
    it do
      api_get endpoint, params: { state: [:pending, :active] }, token: token
      expect(response.status).to eq 200
      expect(response_body.count).to eq(Beneficiary.where(member: member, state: %w[pending active]).count)
    end
  end

  context 'blockchain key' do
    let!(:beneficiary) { create_list(:beneficiary, 3, member: member, blockchain_key: 'btc-testnet', state: :active) }
    it do
      api_get endpoint, params: { blockchain_key: 'btc-testnet' }, token: token
      expect(response.status).to eq 200
      expect(response_body.all? { |b| b['blockchain_key'] == 'btc-testnet' }).to be_truthy
    end
  end

  context 'both currency and state' do
    let!(:active_btc_beneficiaries_for_member) do
      create_list(:beneficiary, 3, member: member, state: :active)
    end

    it do
      api_get endpoint, params: { currency: :btc, state: :active }, token: token
      expect(response.status).to eq 200
      expect(response_body.all? { |b| b['currency'] == 'btc' && b['state'] == 'active' }).to be_truthy
    end
  end

  context 'unauthorized' do
    before do
      Ability.stubs(:user_permissions).returns([])
    end

    let!(:active_btc_beneficiaries_for_member) do
      create_list(:beneficiary, 3, member: member, state: :active)
    end

    it 'renders unauthorized error' do
      api_get endpoint, params: { currency: :btc, state: :active }, token: token
      expect(response).to have_http_status 403
      expect(response).to include_api_error('user.ability.not_permitted')
    end
  end
end

describe API::V2::Account::Beneficiaries, 'GET /:id', type: :request do
  let(:endpoint) { '/api/v2/account/beneficiaries' }

  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  def response_body
    JSON.parse(response.body)
  end

  context 'pending beneficiary' do
    let(:endpoint) { "/api/v2/account/beneficiaries/#{pending_beneficiary.id}" }

    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    it do
      api_get endpoint, token: token
      expect(response.status).to eq 200
      expect(response_body['id']).to eq pending_beneficiary.id
    end
  end

  context 'active beneficiary' do
    let(:endpoint) { "/api/v2/account/beneficiaries/#{active_beneficiary.id}" }

    let!(:active_beneficiary) { create(:beneficiary, state: :active, member: member) }

    it do
      api_get endpoint, token: token
      expect(response.status).to eq 200
      expect(response_body['id']).to eq active_beneficiary.id
    end
  end

  context 'fiat beneficiary' do
    let!(:fiat_beneficiary) { create(:beneficiary, currency: Currency.find('usd'), member: member) }
    let(:endpoint) { "/api/v2/account/beneficiaries/#{fiat_beneficiary.id}" }

    it do
      api_get endpoint, token: token
      expect(response.status).to eq 200
      expect(response_body['id']).to eq fiat_beneficiary.id
      expect(response_body['data']['account_number']).to eq fiat_beneficiary.masked_account_number
    end
  end

  context 'archived beneficiary' do
    let(:endpoint) { "/api/v2/account/beneficiaries/#{archived_beneficiary.id}" }

    let!(:archived_beneficiary) { create(:beneficiary, state: :archived, member: member) }

    it do
      api_get endpoint, token: token
      expect(response.status).to eq 404
    end
  end

  context 'other member beneficiary' do
    let(:endpoint) { "/api/v2/account/beneficiaries/#{pending_beneficiary.id}" }

    let(:member2) { create(:member, :level_3) }

    let!(:pending_beneficiary) { create(:beneficiary, member: member2) }

    it do
      api_get endpoint, token: token
      expect(response.status).to eq 404
    end
  end

  context 'unauthorized' do
    before do
      Ability.stubs(:user_permissions).returns([])
    end

    let(:endpoint) { "/api/v2/account/beneficiaries/#{pending_beneficiary.id}" }

    let(:member2) { create(:member, :level_3) }

    let!(:pending_beneficiary) { create(:beneficiary, member: member2) }

    it 'renders unauthorized error' do
      api_get endpoint, token: token

      expect(response).to have_http_status 403
      expect(response).to include_api_error('user.ability.not_permitted')
    end
  end
end

describe API::V2::Account::Beneficiaries, 'POST', type: :request do
  before { Vault::TOTP.stubs(:validate?).returns(true) }

  let(:endpoint) { '/api/v2/account/beneficiaries' }

  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  let(:beneficiary_data) do
    {
      currency: :btc,
      blockchain_key: 'btc-testnet',
      name: 'Personal Bitcoin wallet',
      description: 'Multisignature Bitcoin Wallet',
      otp: 123456,
      data: {
        address: Faker::Blockchain::Bitcoin.address
      }
    }
  end

  def response_body
    JSON.parse(response.body)
  end

  context 'without JWT' do
    it do
      post endpoint
      expect(response.status).to eq 401
    end
  end

  context 'invalid params' do
    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
        Vault::TOTP.stubs(:validate?).returns(true)
      end

      it 'renders unauthorized error' do
        api_post endpoint, params: beneficiary_data.merge(description: Faker::String.random(120)), token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    context 'missing required params' do
      %i[currency name data].each do |rp|
        context rp do
          it do
            api_post endpoint, params: beneficiary_data.except(rp), token: token
            expect(response.status).to eq 422
            expect(response).to include_api_error("account.beneficiary.missing_#{rp}")
          end
        end
      end
    end

    context 'currency doesn\'t exist' do
      it do
        api_post endpoint, params: beneficiary_data.merge(currency: :uah), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.currency.doesnt_exist')
      end
    end

    context 'name is too long' do
      it do
        api_post endpoint, params: beneficiary_data.merge(name: Faker::String.random(65)), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.too_long_name')
      end
    end

    context 'invalid blockchain_key' do
      it do
        api_post endpoint, params: beneficiary_data.merge(blockchain_key: ''), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.blockchain_key_doesnt_exist')
      end
    end

    context 'description is too long' do
      it do
        api_post endpoint, params: beneficiary_data.merge(description: Faker::String.random(256)), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.too_long_description')
      end
    end

    context 'data has invalid type' do
      it do
        api_post endpoint, params: beneficiary_data.merge(data: 'data'), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.non_json_data')
      end
    end

    context 'crypto beneficiary' do
      context 'nil address in data' do
        it do
          beneficiary_data[:data][:address] = nil
          api_post endpoint, params: beneficiary_data, token: token
          expect(response.status).to eq 422
          expect(response).to include_api_error('account.beneficiary.missing_address_in_data')
        end
      end

      context 'data without address' do
        it do
          beneficiary_data[:data].delete(:address)
          beneficiary_data[:data][:memo] = :memo

          api_post endpoint, params: beneficiary_data, token: token
          expect(response.status).to eq 422
          expect(response).to include_api_error('account.beneficiary.missing_address_in_data')
        end
      end

      context 'unknown network' do
        let(:currency) { Currency.find_by(id: 'btc')}

        before do
          currency.update(default_network_id: nil)
        end

        it do
          beneficiary_data[:blockchain_key] = 'eth-rinkeby'

          api_post endpoint, params: beneficiary_data, token: token
          expect(response.status).to eq 422
          expect(response).to include_api_error('account.beneficiary.network_not_found')
        end
      end

      context 'disabled withdrawal for currency' do
        let(:currency) { Currency.find(:btc) }
        let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :btc)}
        before do
          blockchain_currency.update(withdrawal_enabled: false)
        end
        it do
          api_post endpoint, params: beneficiary_data, token: token
          expect(response.status).to eq 422
          expect(response).to include_api_error('account.currency.withdrawal_disabled')
        end
      end

      context 'invalid character in address' do
        before do
          beneficiary_data[:data][:address] = "'" + Faker::Blockchain::Bitcoin.address
        end
        it do
          api_post endpoint, params: beneficiary_data, token: token
          expect(response.status).to eq 422
          expect(response).to include_api_error('account.beneficiary.failed_to_create')
        end
      end

      context 'duplicated address' do
        context 'same currency' do
          before do
            create(:beneficiary,
                   member: member,
                   blockchain_key: beneficiary_data[:blockchain_key],
                   currency_id: beneficiary_data[:currency],
                   data: {address: beneficiary_data.dig(:data, :address)})
          end

          it do
            api_post endpoint, params: beneficiary_data, token: token
            expect(response.status).to eq 422
            expect(response).to include_api_error('account.beneficiary.duplicate_address')
          end
        end

        context 'different currencies' do
          before do
            create(:beneficiary,
                   member: member,
                   currency_id: :eth,
                   blockchain_key: 'eth-rinkeby',
                   data: {address: beneficiary_data.dig(:data, :address)})
          end

          it do
            api_post endpoint, params: beneficiary_data, token: token
            expect(response.status).to eq 201
          end
        end

        context 'truncates spaces in address' do
          let(:address) { Faker::Blockchain::Bitcoin.address }

          before do
            beneficiary_data[:data][:address] = " " + address + " "
          end
          it do
            api_post endpoint, params: beneficiary_data, token: token
            expect(response.status).to eq 201

            result = JSON.parse(response.body)
            expect(Beneficiary.find(result['id']).data['address']).to eq(address)
          end
        end
      end

      context 'destination tag in address' do
        before do
          beneficiary_data[:data][:address] = Faker::Blockchain::Bitcoin.address + "?dt=4"
        end
        it do
          api_post endpoint, params: beneficiary_data, token: token
          expect(response.status).to eq 201

          result = JSON.parse(response.body)
          expect(Beneficiary.find(result['id']).data['address']).to eq(beneficiary_data[:data][:address])
        end
      end

      # TODO: Test nil full_name in data for both fiat and crypto.
    end

    context 'fiat beneficiary' do
      let(:fiat_beneficiary_data) do
        {
          currency: :usd,
          blockchain_key: 'fiat',
          name: Faker::Bank.name,
          description: Faker::Company.catch_phrase,
          data: generate(:fiat_beneficiary_data),
          otp: 123456
        }
      end

      context 'nil address in data' do
        it do
          fiat_beneficiary_data[:data].delete(:address)
          api_post endpoint, params: fiat_beneficiary_data, token: token
          expect(response.status).to eq 201
          expect(response_body['data']['account_number']).not_to eq fiat_beneficiary_data[:data][:account_number]
        end
      end

      context 'nil data' do
        it do
          fiat_beneficiary_data[:data] = nil
          api_post endpoint, params: fiat_beneficiary_data.except(:data), token: token
          expect(response.status).to eq 422
          expect(response).to include_api_error('account.beneficiary.empty_data')
        end
      end

      context 'duplicated address' do
        context 'same currency' do
          before do
            create(:beneficiary,
                   member: member,
                   currency_id: fiat_beneficiary_data[:currency],
                   data: fiat_beneficiary_data[:data])
          end

          it do
            api_post endpoint, params: fiat_beneficiary_data, token: token
            expect(response.status).to eq 201
          end
        end
      end
    end
  end

  context 'valid params' do
    it 'creates beneficiary for member' do
      expect do
        api_post endpoint, params: beneficiary_data, token: token
      end.to change{ member.beneficiaries.count }.by(1)
    end

    it 'creates beneficiary with pending state' do
      api_post endpoint, params: beneficiary_data, token: token
      expect(response.status).to eq 201
      id = response_body['id']
      expect(Beneficiary.find_by!(id: id).state).to eq 'pending'
    end
  end
end

describe API::V2::Account::Beneficiaries, 'PATCH /activate', type: :request do

  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  def response_body
    JSON.parse(response.body)
  end

  context 'invalid params' do
    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    let(:activation_data) do
      { id:  pending_beneficiary.id,
        pin: pending_beneficiary.pin }
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      let(:endpoint) do
        "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/activate"
      end

      it 'renders unauthorized error' do
        api_patch endpoint, params: activation_data, token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    context 'id has invalid type' do
      let(:endpoint) do
        "/api/v2/account/beneficiaries/id/activate"
      end

      it do
        api_patch endpoint, params: activation_data.merge(id: :id), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.non_integer_id')
      end
    end

    context 'pin has invalid type' do
      let(:endpoint) do
        "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/activate"
      end

      it do
        api_patch endpoint, params: activation_data.merge(pin: :pin), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.non_integer_pin')
      end
    end
  end

  context 'pending beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/activate"
    end

    let(:activation_data) do
      { id:  pending_beneficiary.id,
        pin: pending_beneficiary.pin }
    end

    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    context 'valid pin' do
      it do
        api_patch endpoint, params: activation_data, token: token
        expect(response.status).to eq 200
        expect(response_body['id']).to eq pending_beneficiary.id
        expect(response_body['state']).to eq 'active'
      end
    end

    context 'invalid pin' do
      it do
        activation_data[:pin] = activation_data[:pin] + 1
        api_patch endpoint, params: activation_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.invalid_pin')
      end
    end
  end

  context 'active beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{active_beneficiary.id}/activate"
    end

    let(:activation_data) do
      { id:  active_beneficiary.id,
        pin: active_beneficiary.pin }
    end

    let!(:active_beneficiary) { create(:beneficiary, state: :active, member: member) }

    context 'valid pin' do
      it do
        api_patch endpoint, params: activation_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.cant_activate')
      end
    end

    context 'invalid pin' do
      it do
        activation_data[:pin] = activation_data[:pin] + 1
        api_patch endpoint, params: activation_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.cant_activate')
      end
    end
  end

  context 'archived beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{archived_beneficiary.id}/activate"
    end

    let(:activation_data) do
      { id:  archived_beneficiary.id,
        pin: archived_beneficiary.pin }
    end

    let!(:archived_beneficiary) { create(:beneficiary, state: :archived, member: member) }

    context 'any pin' do
      it do
        api_patch endpoint, params: activation_data, token: token
        expect(response.status).to eq 404
      end
    end
  end

  context 'other user beneficiary' do
    let(:member2) { create(:member, :level_3) }

    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/activate"
    end

    let(:activation_data) do
      { id:  pending_beneficiary.id,
        pin: pending_beneficiary.pin }
    end

    let!(:pending_beneficiary) { create(:beneficiary, member: member2) }

    context 'any pin' do
      it do
        api_patch endpoint, params: activation_data, token: token
        expect(response.status).to eq 404
      end
    end
  end
end

describe API::V2::Account::Beneficiaries, 'PATCH /resend_pin', type: :request do

  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  def response_body
    JSON.parse(response.body)
  end

  context 'invalid params' do
    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    let(:resend_data) do
      { id: pending_beneficiary.id }
    end

    context 'id has invalid type' do
      let(:endpoint) do
        "/api/v2/account/beneficiaries/id/resend_pin"
      end

      it do
        api_patch endpoint, params: resend_data.merge(id: :id), token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.non_integer_id')
      end
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      let(:endpoint) do
        "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/resend_pin"
      end

      it 'renders unauthorized error' do
        api_patch endpoint, params: resend_data, token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end

  context 'pending beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/resend_pin"
    end

    let(:resend_data) do
      { id: pending_beneficiary.id }
    end

    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    context '1 minute from last request on create or resend passed' do
      it do
        pending_beneficiary.update(sent_at: 1.minute.ago)
        api_patch endpoint, params: resend_data, token: token
        expect(response.status).to eq 204
      end
    end

    context '1 minute from last request on create or resend not passed' do
      it do
        api_patch endpoint, params: resend_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.cant_resend_within_1_minute')
        expect(response_body.include?("sent_at")).to eq true
      end
    end
  end

  context 'active beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{active_beneficiary.id}/resend_pin"
    end

    let(:resend_data) do
      { id: active_beneficiary.id }
    end

    let!(:active_beneficiary) { create(:beneficiary, state: :active, member: member) }

    context '1 minute from last request on create or resend passed' do
      it do
        api_patch endpoint, params: resend_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.cant_resend')
      end
    end

    context '1 minute from last request on create or resend not passed' do
      it do
        api_patch endpoint, params: resend_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.cant_resend')
      end
    end
  end

  context 'archived beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{archived_beneficiary.id}/resend_pin"
    end

    let(:resend_data) do
      { id:  archived_beneficiary.id }
    end

    let!(:archived_beneficiary) { create(:beneficiary, state: :archived, member: member) }

    it do
      api_patch endpoint, params: resend_data, token: token
      expect(response.status).to eq 404
    end
  end

  context 'other user beneficiary' do
    let(:member2) { create(:member, :level_3) }

    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{pending_beneficiary.id}/resend_pin"
    end

    let(:activation_data) do
      { id:  pending_beneficiary.id,
        pin: pending_beneficiary.pin }
    end

    let!(:pending_beneficiary) { create(:beneficiary, member: member2) }

    it do
      api_patch endpoint, params: activation_data, token: token
      expect(response.status).to eq 404
    end
  end
end

describe API::V2::Account::Beneficiaries, 'DELETE /:id', type: :request do

  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:delete_data) do
    { otp: 111111 }
  end

  def response_body
    JSON.parse(response.body)
  end

  before { Vault::TOTP.stubs(:validate?).returns(true) }

  context 'invalid params' do
    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    let(:activation_data) do
      { id:  pending_beneficiary.id,
        pin: pending_beneficiary.pin }
    end

    context 'id has invalid type' do
      let(:endpoint) do
        "/api/v2/account/beneficiaries/id"
      end

      it do
        api_delete endpoint, params: delete_data, token: token
        expect(response.status).to eq 422
        expect(response).to include_api_error('account.beneficiary.non_integer_id')
      end
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      let(:endpoint) do
        "/api/v2/account/beneficiaries/#{pending_beneficiary.id}"
      end

      it 'renders unauthorized error' do
        api_delete endpoint, params: delete_data, token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end

  context 'pending beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{pending_beneficiary.id}"
    end

    let!(:pending_beneficiary) { create(:beneficiary, member: member) }

    it do
      api_delete endpoint, params: delete_data, token: token
      expect(response.status).to eq 204
      expect(response.body).to be_empty
    end
  end

  context 'active beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{active_beneficiary.id}"
    end

    let!(:active_beneficiary) { create(:beneficiary, state: :active, member: member) }

    it do
      api_delete endpoint, params: delete_data, token: token
      expect(response.status).to eq 204
      expect(response.body).to be_empty
    end
  end

  context 'archived beneficiary' do
    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{archived_beneficiary.id}"
    end

    let!(:archived_beneficiary) { create(:beneficiary, state: :archived, member: member) }

    it do
      api_delete endpoint, params: delete_data, token: token
      expect(response.status).to eq 404
    end
  end

  context 'other user beneficiary' do
    let(:member2) { create(:member, :level_3) }

    let(:endpoint) do
      "/api/v2/account/beneficiaries/#{pending_beneficiary.id}"
    end

    let!(:pending_beneficiary) { create(:beneficiary, member: member2) }

    it do
      api_delete endpoint, params: delete_data, token: token
      expect(response.status).to eq 404
    end
  end
end


