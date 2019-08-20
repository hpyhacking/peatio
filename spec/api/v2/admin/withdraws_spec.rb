# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Withdraws, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }
  before do
    [admin, level_3_member].each do |member|
      member.accounts.map { |a| a.update(balance: 500) }
    end

    create(:usd_withdraw, amount: 10.0, sum: 10.0, member: admin)
    create(:usd_withdraw, amount: 9.0, sum: 9.0, member: admin)
    create(:usd_withdraw, amount: 100.0, sum: 100.0, member: level_3_member)
    create(:btc_withdraw, amount: 42.0, sum: 42.0, txid: 'special_txid', member: admin)
    create(:btc_withdraw, amount: 11.0, sum: 11.0, member: level_3_member)
    create(:btc_withdraw, amount: 12.0, sum: 12.0, member: level_3_member)
  end

  describe 'GET /api/v2/admin/withdraws' do
    let(:url) { '/api/v2/admin/withdraws' }

    it 'get all withdraws' do
      api_get url, token: token

      actual = JSON.parse(response.body)
      expected = Withdraw.all

      expect(actual.length).to eq expected.length
      expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
      expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
      expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
      expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.coin? ? 'coin' : 'fiat' })
    end

    context 'ordering' do
      it 'ascending by id' do
        api_get url, token: token, params: { order_by: 'id', ordering: 'asc' }

        actual = JSON.parse(response.body)
        expected = Withdraw.order(id: 'asc')

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'descending by sum' do
        api_get url, token: token, params: { order_by: 'sum', ordering: 'desc' }

        actual = JSON.parse(response.body)
        expected = Withdraw.order(sum: 'desc')

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end
    end

    context 'filtering' do
      it 'by member' do
        api_get url, token: token, params: { uid: level_3_member.uid }

        actual = JSON.parse(response.body)
        expected = Withdraw.where(member_id: level_3_member.id)

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['member'] }).to all eq level_3_member.id
        expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.coin? ? 'coin' : 'fiat' })
      end

      it 'by type' do
        api_get url, token: token, params: { type: 'coin' }

        actual = JSON.parse(response.body)
        expected = Withdraw.where(type: 'Withdraws::Coin')

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
        expect(actual.map { |a| a['type'] }).to all eq 'coin'
      end

      it 'by txid' do
        api_get url, token: token, params: { txid: Withdraw.where(type: 'Withdraws::Coin').first.txid }

        actual = JSON.parse(response.body)
        expected = Withdraw.where(type: 'Withdraws::Coin').first

        expect(actual.length).to eq 1
        expect(actual.first['state']).to eq expected.aasm_state
        expect(actual.first['id']).to eq expected.id
        expect(actual.first['currency']).to eq expected.currency_id
        expect(actual.first['member']).to eq expected.member_id
        expect(actual.first['type']).to eq 'coin'
      end
    end
  end
end
