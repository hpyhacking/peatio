# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Deposits, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }
  let!(:fiat_deposits) do
    [
      create(:deposit_usd, amount: 10.0),
      create(:deposit_usd, amount: 9.0),
      create(:deposit_usd, amount: 100.0, member: level_3_member),
    ]
  end
  let!(:coin_deposits) do
    [
      create(:deposit_btc, amount: 102.0),
      create(:deposit_btc, amount: 11.0, member: level_3_member),
      create(:deposit_btc, amount: 12.0, member: level_3_member),
    ]
  end

  describe 'GET /api/v2/admin/deposits' do
    let(:url) { '/api/v2/admin/deposits' }

    it 'get all deposits' do
      api_get url, token: token

      actual = JSON.parse(response.body)
      expected = coin_deposits + fiat_deposits

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
        expected = (coin_deposits + fiat_deposits).sort { |a, b| a.id <=> b.id }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'descending by amount' do
        api_get url, token: token, params: { order_by: 'amount', ordering: 'desc' }

        actual = JSON.parse(response.body)
        expected = (coin_deposits + fiat_deposits).sort { |a, b| b.amount <=> a.amount }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'ordering by unexisting field' do
        api_get url, token: token, params: { order_by: 'cutiness', ordering: 'desc' }

        actual = JSON.parse(response.body)
        expected = coin_deposits + fiat_deposits

        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      end
    end

    context 'filtering' do
      it 'by member' do
        api_get url, token: token, params: { uid: level_3_member.uid }

        actual = JSON.parse(response.body)
        expected = (coin_deposits + fiat_deposits).select { |d| d.member_id == level_3_member.id }

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
        expected = coin_deposits

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
        expect(actual.map { |a| a['type'] }).to all eq 'coin'
      end
    end
  end
end
