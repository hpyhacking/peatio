# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Members, type: :request do
  let(:uid) { 'ID00FEE1DEAD' }
  let(:email) { 'someone@mailbox.com' }
  let(:admin) { create(:member, :admin, :level_3, email: email, uid: uid) }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member, :level_3) }
  let(:member_token) { jwt_for(member) }
  let!(:members) do
    [
      create(:member, role: 'admin', state: 'pending'),
      create(:member, role: 'admin', state: 'active'),
      create(:member, group: 'any'),
    ]
  end

  describe 'GET' do
    context 'authentication' do
      it 'requires token' do
        get '/api/v2/admin/members'
        expect(response.code).to eq '401'
      end

      it 'validates permissions' do
        api_get'/api/v2/admin/members', token: member_token
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'authenticate admin' do
        api_get'/api/v2/admin/members', token: token
        expect(response).to be_successful
      end
    end

    context 'filtering' do
      it 'returns all members' do
        api_get'/api/v2/admin/members', token: token
        result = JSON.parse(response.body)

        expect(result.length).to eq(Member.count)
      end

      it 'filters by role & state' do
        api_get'/api/v2/admin/members', token: token, params: { role: 'admin', state: 'active' }
        result = JSON.parse(response.body)
        expected = Member.where(role: 'admin', state: 'active').pluck(:id)

        expect(result.map { |r| r['id'] }).to match_array expected
      end

      it 'filters by group' do
        api_get'/api/v2/admin/members', token: token, params: { group: 'any' }
        result = JSON.parse(response.body)
        expected = Member.where(group: 'any').pluck(:id)

        expect(result.map { |r| r['id'] }).to match_array expected
      end

      it 'filters by uid' do
        api_get'/api/v2/admin/members', token: token, params: { uid: uid }
        result = JSON.parse(response.body)
        expect(result.length).to eq 1
        expect(result.first['id']).to eq admin.id
      end
    end

    context 'accounts' do
      before { admin.touch_accounts }
      it 'returns accounts for all currencies' do
        api_get'/api/v2/admin/members', token: token, params: { uid: uid }
        result = JSON.parse(response.body)
        expect(result.first['accounts'].count).to eq(Currency.count)
      end
    end
  end

  describe 'Get by uid' do
    context 'authentication' do
      it 'requires token' do
        get "/api/v2/admin/members/#{member.uid}"
        expect(response.code).to eq '401'
      end

      it 'validates permissions' do
        api_get "/api/v2/admin/members/#{member.uid}", token: member_token
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'authenticate admin' do
        api_get "/api/v2/admin/members/#{member.uid}", token: token
        expect(response).to be_successful
      end
    end

    context 'get user by uid' do
      let!(:account) { member.touch_accounts }
      let(:address) { Faker::Blockchain::Ethereum.address }
      let(:coin) { Currency.find(:btc) }

      let!(:beneficiary) { create(:beneficiary,
                                  member: member,
                                  currency: coin,
                                  state: :active,
                                  data: generate(:coin_beneficiary_data).merge(address: address)) }


      it 'returns user entities' do
        api_get "/api/v2/admin/members/UID1234", token: token
        expect(response.code).to eq '404'

        expect(response).to include_api_error('record.not_found')
      end

      it 'returns user entities' do
        api_get "/api/v2/admin/members/#{member.uid}", token: token
        expect(response).to be_successful
        result = JSON.parse(response.body)

        expect(result['uid']).to eq(member.uid)
        expect(result['email']).to eq(member.email)
        expect(result['uid']).to eq(member.uid)
        expect(result['group']).to eq(member.group)
        expect(result['accounts'][0]['currency']).to eq(member.accounts[0].currency.id)
        expect(result['accounts'][0]['balance']).to eq(member.accounts[0].balance.to_s)
        expect(result['accounts'][0]['locked']).to eq(member.accounts[0].locked.to_s)
        expect(result['beneficiaries'][0]['currency']).to eq(member.beneficiaries[0].currency_id)
        expect(result['beneficiaries'][0]['data']['address']).to eq(member.beneficiaries[0].data['address'])
      end

      context 'fiat beneficiary' do
        let(:fiat) { Currency.find(:usd) }

        let!(:beneficiary) { create(:beneficiary,
                                    member: member,
                                    currency: fiat,
                                    state: :active,
                                    data: generate(:fiat_beneficiary_data)) }

        it 'returns user entities' do
          api_get "/api/v2/admin/members/#{member.uid}", token: token
          expect(response).to be_successful
          result = JSON.parse(response.body)

          expect(result['uid']).to eq(member.uid)
          expect(result['email']).to eq(member.email)
          expect(result['uid']).to eq(member.uid)
          expect(result['group']).to eq(member.group)
          expect(result['accounts'][0]['currency']).to eq(member.accounts[0].currency.id)
          expect(result['accounts'][0]['balance']).to eq(member.accounts[0].balance.to_s)
          expect(result['accounts'][0]['locked']).to eq(member.accounts[0].locked.to_s)
          expect(result['beneficiaries'][0]['currency']).to eq(member.beneficiaries[0].currency_id)
          expect(result['beneficiaries'][0]['data']['address']).to eq(member.beneficiaries[0].data['address'])
          expect(result['beneficiaries'][0]['data']['account_number']).to eq(member.beneficiaries[0].data['account_number'])
        end
      end
    end
  end

  describe 'GET /api/v2/admin/members/groups' do
    it 'get list of all existing groups' do
      api_get '/api/v2/admin/members/groups', token: token
      expect(JSON.parse(response.body)).to match_array Member.groups.map &:to_s
    end
  end

  describe 'POST /api/v2/admin/members/groups' do
    it 'returns user with updated role' do
      api_put "/api/v2/admin/members/#{member.uid}", token: token, params: { group: 'vip-2' }
      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['group']).to eq('vip-2')
    end

    it 'returns user with updated group' do
      api_put "/api/v2/admin/members/#{member.uid}", token: token, params: { group: ' Vip-2 ' }
      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['group']).to eq('vip-2')
    end

    it 'returns status 404 and error' do
      api_put "/api/v2/admin/members/U1234", token: token, params: { group: 'vip-2' }
      expect(response).to have_http_status(404)
      expect(response).to include_api_error('record.not_found')
    end

    it 'validate params' do
      api_put "/api/v2/admin/members/#{member.uid}", token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('admin.member.missing_group')
    end
  end
end
