# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Operations, type: :request do
  let(:uid) { 'ID00FEE1DEAD' }
  let(:email) { 'someone@mailbox.com' }
  let(:admin) { create(:member, :admin, :level_3, email: email, uid: uid) }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member, :level_3) }
  let(:member_token) { jwt_for(member) }

  describe 'GET' do
    context 'authentication' do
      it 'requires token' do
        get '/api/v2/admin/assets'
        expect(response.code).to eq '401'
      end

      it 'validates permissions' do
        api_get'/api/v2/admin/expenses', token: member_token
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'authenticate admin' do
        api_get'/api/v2/admin/liabilities', token: token
        expect(response).to be_successful
      end
    end

    context 'assets' do
      let!(:assets) do
        [
          create(:asset, currency: Currency.find(:btc), debit: 80.0),
          create(:asset, currency: Currency.find(:btc), debit: 120.0),
          create(:asset, currency: Currency.find(:usd), debit: 220.0),
        ]
      end

      it 'entity present valid fields' do
        api_get '/api/v2/admin/assets', token: token
        result = JSON.parse(response.body)
        expected = %w[id rid currency reference_type credit debit created_at code account_kind]

        expect(result.first.keys).to match_array expected
      end

      it 'filters by currency' do
        api_get '/api/v2/admin/assets', token: token, params: { currency: 'usd' }
        result = JSON.parse(response.body)
        expected = assets.select { |a| a.currency_id == 'usd' }

        expect(result.map { |a| a['id'] }).to match_array expected.map { |e| e.id }
      end

      it 'orders by debit ascending' do
        api_get '/api/v2/admin/assets', token: token, params: { order_by: 'debit', ordering: 'asc' }
        result = JSON.parse(response.body)
        expected = assets.sort { |a, b| a.debit <=> b.debit }

        expect(result.map { |a| a['id'] }).to match_array expected.map { |e| e.id }
      end
    end

    context 'expenses' do
      let!(:expenses) do
        [
          create(:expense, created_at: 5.days.ago, reference_type: 'Deposit'),
          create(:expense, created_at: 2.days.ago, reference_type: 'Trade'),
          create(:expense, created_at: 2.days.ago, reference_type: 'Deposit'),
        ]
      end

      it 'entity presents valid fields' do
        api_get '/api/v2/admin/expenses', token: token
        result = JSON.parse(response.body)
        expected = %w[id rid currency reference_type credit debit created_at code account_kind]

        expect(result.first.keys).to match_array expected
      end

      it 'filters by reference type' do
        api_get '/api/v2/admin/expenses', token: token, params: { reference_type: 'Deposit' }
        result = JSON.parse(response.body)
        expected = expenses.select { |a| a.reference_type == 'Deposit' }

        expect(result.map { |e| e['id'] }).to match_array expected.map { |e| e.id }
      end

      it 'fileters by created_at_to' do
        api_get '/api/v2/admin/expenses', token: token, params: { range: 'created', to: 3.days.ago }
        result = JSON.parse(response.body)
        expected = expenses.select { |l| l.created_at < 3.days.ago }

        expect(result.map { |a| a['id'] }).to match_array expected.map { |e| e.id }
      end

      it 'filters by created_at_from' do
        api_get '/api/v2/admin/expenses', token: token, params: { range: 'created', from: 3.days.ago }
        result = JSON.parse(response.body)
        expected = expenses.select { |l| l.created_at >= 3.days.ago }

        expect(result.map { |a| a['id'] }).to match_array expected.map { |e| e.id }
      end
    end

    context 'revenues' do
      let!(:revenues) do
        [
          create(:revenue, code: 301, currency: Currency.find(:usd), reference_id: 1),
          create(:revenue, code: 302, currency: Currency.find(:btc), reference_id: 1),
          create(:revenue, code: 302, currency: Currency.find(:btc), reference_id: 2),
        ]
      end

      it 'entity presents valid fields' do
        api_get '/api/v2/admin/revenues', token: token
        result = JSON.parse(response.body)
        expected = %w[id rid currency reference_type credit debit created_at code account_kind]

        expect(result.first.keys).to match_array expected
      end

      it 'filters by code' do
        api_get '/api/v2/admin/revenues', token: token, params: { code: 302 }
        result = JSON.parse(response.body)
        expected = revenues.select { |a| a.code == 302 }

        expect(result.map { |r| r['id'] }).to match_array expected.map { |e| e.id }
      end

      it 'filters by reference id' do
        api_get '/api/v2/admin/revenues', token: token, params: { rid: 1 }
        result = JSON.parse(response.body)
        expected = revenues.select { |a| a.reference_id == 1 }

        expect(result.map { |r| r['id'] }).to match_array expected.map { |e| e.id }
      end
    end

    context 'liabilities' do
      let!(:liabilities) do
        [
          create(:liability, member: member, credit: 110.0),
          create(:liability, member: member, credit: 190.0),
          create(:liability, member: admin, credit: 80.0),
        ]
      end

      it 'entity presents valid fields' do
        api_get '/api/v2/admin/liabilities', token: token
        result = JSON.parse(response.body)
        expected = %w[id rid currency reference_type credit debit created_at code uid account_kind]

        expect(result.first.keys).to match_array expected
      end

      it 'filters by member uid' do
        api_get '/api/v2/admin/liabilities', token: token, params: { uid: member.uid }
        result = JSON.parse(response.body)
        expected = liabilities.select { |l| l.member.uid == member.uid }

        expect(result.map { |a| a['id'] }).to match_array expected.map { |e| e.id }
      end

      it 'orders by credit descending' do
        api_get '/api/v2/admin/liabilities', token: token, params: { order_by: 'credit', ordering: 'asc' }
        result = JSON.parse(response.body)
        expected = liabilities.sort { |a, b| b.credit <=> a.credit }

        expect(result.map { |a| a['id'] }).to match_array expected.map { |e| e.id }
      end
    end
  end
end
