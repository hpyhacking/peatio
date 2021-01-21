# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::InternalTransfers, type: :request do
  let(:endpoint) { '/api/v2/admin/internal_transfers' }
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0', username: 'test') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3, uid: 'ID84BF61C8H0', username: 'member') }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/internal_transfer' do
    let!(:internal_transfer_btc) { create_list(:internal_transfer_btc, 4, :with_deposit_liability, sender: admin, receiver: level_3_member) }
    let!(:internal_transfer_usd) { create_list(:internal_transfer_usd, 3, :with_deposit_liability, sender: level_3_member) }

    it 'lists of internal transfers' do
      api_get endpoint, token: token

      expect(response).to be_successful
      expect(response_body.size).to eq 7
    end

    it 'returns paginated internal transfers' do
      api_get endpoint, params: { limit: 1, page: 1 }, token: token

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '7'
      expect(response_body.size).to eq 1

      api_get endpoint, params: { limit: 1, page: 2 }, token: token

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '7'
      expect(response_body.size).to eq 1
    end

    it 'returns internal transfers by desc order' do
      api_get endpoint, params: { ordering: 'desc' }, token: token

      expect(response).to be_successful
      expect(response_body.first['id']).to eq InternalTransfer.last.id
    end

    it 'returns internal transfers by ascending order' do
      api_get endpoint, params: { ordering: 'asc' }, token: token

      expect(response).to be_successful
      expect(response_body.first['id']).to eq InternalTransfer.first.id
    end

    it 'return error in case of not permitted ability' do
      api_get endpoint, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    context 'filtering' do
      it 'by currency' do
        api_get endpoint, token: token, params: { currency: 'btc' }

        expect(response_body.count).to eq(InternalTransfer.where(currency_id: 'btc').count)
      end

      it 'returns orders for specific sender by uid' do
        api_get endpoint, params: { sender: admin.uid }, token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.map{|r| r['sender_uid']}.size).to eq 4
        expect(result.map{|r| r['sender_uid']}).to all eq admin.uid
      end

      it 'returns orders for specific sender by username' do
        api_get endpoint, params: { sender: admin.username }, token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.map{|r| r['sender_username']}.size).to eq 4
        expect(result.map{|r| r['sender_username']}).to all eq admin.username
      end

      it 'returns orders for specific receiver by uid' do
        api_get endpoint, params: { receiver: level_3_member.uid }, token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.map{|r| r['receiver_uid']}.size).to eq 4
        expect(result.map{|r| r['receiver_uid']}).to all eq level_3_member.uid
      end

      it 'returns orders for specific receiver by username' do
        api_get endpoint, params: { receiver: level_3_member.username }, token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.map{|r| r['receiver_username']}.size).to eq 4
        expect(result.map{|r| r['receiver_username']}).to all eq level_3_member.username
      end
    end
  end
end
