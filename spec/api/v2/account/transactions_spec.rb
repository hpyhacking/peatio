# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::Transactions, type: :request do
  describe 'GET /api/v2/account/transactions' do
    let(:member) { create(:member, :level_3) }
    let(:token) { jwt_for(member) }
    let(:btc_account) { member.accounts.with_currency('btc').first }
    let(:usd_account) { member.accounts.with_currency('usd').first }
    let(:balance) { 100000 }

    context 'successful' do
      before do
        btc_account.plus_funds(balance)
        usd_account.plus_funds(balance)
        create_list(:deposit_usd, 4, member: member, updated_at: 5.hour.ago)
        create_list(:usd_withdraw, 4, member: member, updated_at: 5.hour.ago)
        create_list(:deposit_btc, 3, member: member, updated_at: 10.hour.ago)
        create_list(:btc_withdraw, 3, member: member, updated_at: 10.hour.ago)
        create_list(:deposit_usd, 5, member: member, updated_at: 5.days.ago)
        create_list(:usd_withdraw, 5, member: member, updated_at: 5.days.ago)
      end

      it 'returns all deposits and withdraws num' do
        api_get '/api/v2/account/transactions', token: token
        result = JSON.parse(response.body)
        expect(result.size).to eq 24

        expect(response.headers.fetch('Total')).to eq '24'
      end

      it 'returns limited deposits and withdraws' do
        api_get '/api/v2/account/transactions', params: { limit: 2, page: 1 }, token: token
        result = JSON.parse(response.body)

        expect(result.size).to eq 2
        expect(response.headers.fetch('Total')).to eq '24'

        api_get '/api/v2/account/transactions', params: { limit: 1, page: 2 }, token: token
        result = JSON.parse(response.body)

        expect(result.size).to eq 1
        expect(response.headers.fetch('Total')).to eq '24'
      end

      it 'returns deposits and withdraws for the last two days' do
        api_get '/api/v2/account/transactions', params: { time_from: 2.days.ago.to_i }, token: token
        result = JSON.parse(response.body)

        expect(result.size).to eq 14
        expect(response.headers.fetch('Total')).to eq '14'
      end

      it 'returns deposits and withdraws before 2 days ago' do
        api_get '/api/v2/account/transactions', params: { time_to: 2.days.ago.to_i }, token: token
        result = JSON.parse(response.body)

        expect(result.size).to eq 10
        expect(response.headers.fetch('Total')).to eq '10'
      end

      it 'returns newest mixed up withdraws and deposits depending on updated_at' do
        api_get '/api/v2/account/transactions', params: { limit: 8, page: 1 }, token: token
        result = JSON.parse(response.body)

        expect(result.select { |t| t['type'] == 'Withdraw' }.count).to eq 4
        expect(result.select { |t| t['type'] == 'Deposit' }.count).to eq 4
      end

      it 'returns the oldest mixed up withdraws and deposits depending on updated_at' do
        api_get '/api/v2/account/transactions', params: { limit: 8, page: 2, time_from: 2.days.ago.to_i }, token: token
        result = JSON.parse(response.body)

        expect(result.select { |t| t['type'] == 'Withdraw' }.count).to eq 3
        expect(result.select { |t| t['type'] == 'Deposit' }.count).to eq 3
      end

      it 'returns sorted transactions in descending order' do
        api_get '/api/v2/account/transactions', token: token
        result = JSON.parse(response.body)

        update_time = result.pluck('updated_at')
        expect(update_time).to eq(update_time.sort { |a, b| b <=> a })
      end

      it 'returns sorted transactions in ascending order' do
        api_get '/api/v2/account/transactions', params: { order_by: 'asc' }, token: token
        result = JSON.parse(response.body)
        update_time = result.pluck('updated_at')

        expect(update_time).to eq(update_time.sort)
      end

      it 'returns only transactions with BTC currency' do
        api_get '/api/v2/account/transactions', params: { currency: 'btc' }, token: token
        result = JSON.parse(response.body)

        expect(result.count).to eq 6
      end

      it 'returns only transactions with USD currency' do
        api_get '/api/v2/account/transactions', params: { currency: 'USD' }, token: token
        result = JSON.parse(response.body)

        expect(result.count).to eq 18
      end

      it 'returns nil in confirmations field for fiat' do
        api_get '/api/v2/account/transactions', params: { currency: 'USD' }, token: token
        result = JSON.parse(response.body)

        expect(result.pluck('confimations').none?).to be_truthy
      end

      it 'returns valid number in confirmations field for coin' do
        api_get '/api/v2/account/transactions', params: { currency: 'btc' }, token: token
        result = JSON.parse(response.body)

        expect(result.pluck('confimations').any? { |c| c.nil? ? true : c > 1 }).to be_truthy
      end
    end

    context 'fail' do
      before do
        btc_account.plus_funds(balance)
        usd_account.plus_funds(balance)
      end

      it 'requires authentication' do
        api_get '/api/v2/account/transactions'

        expect(response.code).to eq '401'
      end

      it 'validates currency param' do
        api_get '/api/v2/account/transactions', params: { currency: 'bar' }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.currency_doesnt_exist')
      end

      it 'validates order_by param' do
        api_get '/api/v2/account/transactions', params: { order_by: 'foo' }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.order_by_invalid')
      end

      it 'validates time_from param' do
        api_get '/api/v2/account/transactions', params: { time_from: 'btc' }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.non_integer_time_from')
      end

      it 'validates time_to param' do
        api_get '/api/v2/account/transactions', params: { time_to: [] }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.non_integer_time_to')
      end

      it 'validates page param' do
        api_get '/api/v2/account/transactions', params: { page: -1 }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.non_positive_page')

        api_get '/api/v2/account/transactions', params: { page: 'btc' }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.non_integer_page')
      end

      it 'validates limit param' do
        api_get '/api/v2/account/transactions', params: { limit: 1001 }, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error('account.transactions.invalid_limit')
      end
    end
  end
end
