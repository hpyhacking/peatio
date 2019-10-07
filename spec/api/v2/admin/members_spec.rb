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
      create(:member),
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

      it 'filters by uid' do
        api_get'/api/v2/admin/members', token: token, params: { uid: uid }
        result = JSON.parse(response.body)

        expect(result.length).to eq 1
        expect(result.first['id']).to eq admin.id
      end
    end

    context 'accounts' do
      it 'returns accounts for all currencies' do
        api_get'/api/v2/admin/members', token: token, params: { uid: uid }
        result = JSON.parse(response.body)
        expect(result.first['accounts'].count).to eq(Currency.count)
      end
    end
  end
end
