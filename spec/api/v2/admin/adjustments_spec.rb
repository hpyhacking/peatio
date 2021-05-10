# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Adjustments, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member) }

  describe 'GET /api/v2/admin/adjustments' do
    let!(:adjustments) do
      create(:adjustment, currency_id: 'btc')
      create(:adjustment, currency_id: 'btc')
      create(:adjustment, currency_id: 'btc')
    end
    let!(:accepted) { create(:adjustment, currency_id: 'btc', receiving_account_number: "BTC-202-#{member.uid}").tap { |a| a.accept!(validator: member) } }
    let!(:rejected) { create(:adjustment, currency_id: 'btc', receiving_account_number: "BTC-202-#{member.uid}").tap { |a| a.reject!(validator: member) } }

    it 'get all adjustments' do
      api_get '/api/v2/admin/adjustments', token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers['Total'].to_i).to eq Adjustment.count
      expect(result.length).to eq Adjustment.count
    end

    context 'with rejected/accepted' do
      it 'fetches operations from db' do
        api_get '/api/v2/admin/adjustments', token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.length).to eq 5
        expect(result[0].key?('asset')).to be_truthy
        expect(result[0].key?('liability')).to be_truthy
        expect(result[0]['state']).to eq('rejected')
        # We don't create operations for rejected adj.
        expect(result[0]['liability']['id'].nil?).to be_truthy
        expect(result[0]['asset']['id'].nil?).to be_truthy
        expect(result[1].key?('asset')).to be_truthy
        expect(result[1].key?('liability')).to be_truthy
        expect(result[1]['liability']['id']).to eq accepted.liability.id
        expect(result[1]['asset']['id']).to eq accepted.asset.id
        expect(result[1]['state']).to eq('accepted')
      end
    end

    context 'with filters' do
      let!(:adjustment_with_category) { create(:adjustment, currency_id: 'btc', category: 'balance_anomaly', receiving_account_number: "BTC-202-#{member.uid}") }
      let!(:eth_adjustment) { create(:adjustment, currency_id: 'eth', receiving_account_number: "eth-202-#{member.uid}").tap { |a| a.accept!(validator: member) } }

      it 'filter by accepted state' do
        api_get '/api/v2/admin/adjustments', token: token, params: { state: 'accepted' }
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers['Total'].to_i).to eq(Adjustment.where(state: 'accepted').count)
        expect(result.last['id']).to eq(accepted.id)
      end

      it 'filter by rejected state' do
        api_get '/api/v2/admin/adjustments', token: token, params: { state: 'rejected' }
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers['Total'].to_i).to eq(Adjustment.where(state: 'rejected').count)
        expect(result.first['id']).to eq(rejected.id)
      end

      it 'filters by eth currency' do
        api_get '/api/v2/admin/adjustments', token: token, params: { currency: 'eth' }

        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers['Total'].to_i).to eq(Adjustment.where(currency_id: 'eth').count)
        expect(result.first['id']).to eq(eth_adjustment.id)
      end

      it 'filters by btc currency' do
        api_get '/api/v2/admin/adjustments', token: token, params: { currency: 'btc' }

        expect(response).to be_successful
        expect(response.headers['Total'].to_i).to eq(Adjustment.where(currency_id: 'btc').count)
      end

      it 'validates currency' do
        api_get '/api/v2/admin/adjustments', token: token, params: { currency: 'uah' }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.currency.doesnt_exist')
      end

      it 'filter by accepted category' do
        api_get '/api/v2/admin/adjustments', token: token, params: { category: 'balance_anomaly' }
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers['Total'].to_i).to eq(Adjustment.where(category: 'balance_anomaly').count)
        expect(result.first['id']).to eq(adjustment_with_category.id)
      end
    end
  end

  describe 'GET /api/v2/admin/adjustments/:id' do
    let!(:adjustment1) { create(:adjustment, currency_id: 'btc') }
    let!(:adjustment2) { create(:adjustment, currency_id: 'eth', receiving_account_number: "ETH-202-#{member.uid}") }
    let!(:adjustment3) { create(:adjustment, currency_id: 'eth', receiving_account_number: "ETH-302-#{member.uid}") }

    it 'get specified adjustment' do
      api_get "/api/v2/admin/adjustments/#{adjustment1.id}", token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['id']).to eq adjustment1.id
      expect(result['currency']).to eq adjustment1.currency_id
    end

    it 'get specified adjustment' do
      api_get "/api/v2/admin/adjustments/#{adjustment2.id}", token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['id']).to eq adjustment2.id
      expect(result['currency']).to eq adjustment2.currency_id
      expect(result['receiving_account_code']).to eq '202'
      expect(result['receiving_member_uid']).to eq member.uid
    end

    it 'get specified adjustment' do
      api_get "/api/v2/admin/adjustments/#{adjustment3.id}", token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['id']).to eq adjustment3.id
      expect(result['currency']).to eq adjustment3.currency_id
      expect(result['receiving_account_code']).to eq '302'
      expect(result['receiving_member_uid'].blank?).to be_truthy
    end
  end

  describe 'POST /api/v2/admin/adjustments/new' do
    let(:params) do
      {
        reason: 'Adjustment',
        description: 'sample sdjustment',
        category: 'asset_registration',
        amount: 100.0,
        currency_id: :btc,
        asset_account_code: 102,
        receiving_account_code: 202,
        receiving_member_uid: member.uid
      }
    end

    it 'creates new adjustment' do
      expect {
        api_post '/api/v2/admin/adjustments/new', token: token, params: params
      }.to change { Adjustment.count }.by 1

      expect(response).to be_successful
    end

    it 'returns new adjustment and prebuild operations' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params

      result = JSON.parse(response.body)
      expect(result['reason']).to eq('Adjustment')
      expect(result['description']).to eq('sample sdjustment')
      expect(result['category']).to eq('asset_registration')
      expect(result['amount']).to eq('100.0')
      expect(result['currency']).to eq('btc')
      expect(result.key?('asset')).to be_truthy
      expect(result.key?('liability')).to be_truthy
    end

    it 'checks account decimal amount' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(amount: '100btc')

      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.adjustment.non_decimal_amount')
    end

    it 'checks amount presence' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(amount: '')

      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.adjustment.empty_amount')
    end

    it 'checks right asset_account_code' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(asset_account_code: 111)

      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.adjustment.invalid_asset_account_code')
    end

    it 'checks right receiving_account_code' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(receiving_account_code: 444)

      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.adjustment.invalid_receiving_account_code')
    end

    it 'validates right category' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(category: 'some_category')

      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.adjustment.invalid_category')
    end

    it 'validates right currency' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(currency_id: 'uah')

      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.adjustment.currency_doesnt_exist')
    end

    it 'validates coin and fiat accounts numbers' do
      api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(currency_id: 'btc', asset_account_code: 101)

      expect(response).not_to be_successful
      expect(response).to include_api_error('Prebuild operations are invalid')
    end

    context 'receiving_member_uid validatations' do
      it 'requires for liability receiving account' do
        api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(receiving_account_code: 202).except(:receiving_member_uid)

        expect(response).not_to be_successful
        expect(response).to include_api_error('admin.adjustment.missing_receiving_member_uid')
      end

      it 'doesnt requires for revenue receiving account' do
        api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(receiving_account_code: 302).except(:receiving_member_uid)

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result['reason']).to eq('Adjustment')
      end


      it 'doesnt requires for expense receiving account' do
        api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(receiving_account_code: 402).except(:receiving_member_uid)

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result['reason']).to eq('Adjustment')
      end

      it 'creates adjustment with expense without member_uid' do
        api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(receiving_account_code: 402)

        expect(response).not_to be_successful
        expect(response).to include_api_error('admin.adjustment.redundant_receiving_member_uid')
      end

      it 'creates adjustment with revenue that contains member uid' do
        api_post '/api/v2/admin/adjustments/new', token: token, params: params.merge(receiving_account_code: 302)

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result['reason']).to eq('Adjustment')
        expect(result['receiving_member_uid'].blank?).to be_truthy
        adjustment_db = Adjustment.find(result['id'])
        account_number_hash = Operations.split_account_number(account_number: adjustment_db.receiving_account_number)
        expect(account_number_hash[:member_uid].present?).to be_truthy
      end
    end
  end

  describe 'POST /api/v2/admin/adjustments/action (accept)' do
    let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}") }

    it 'accepts adjustment' do
      expect {
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
      }.to change { adjustment.reload.state }.to('accepted')
      .and change { Operations::Asset.count }.by(1)
      .and change { Operations::Liability.count }.by(1)

      expect(response).to be_successful
    end

    it 'udpates member\'s balance' do
      expect {
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
      }.to change { member.get_account(adjustment.currency).balance }.by(adjustment.amount)
    end

    it 'does not accept invalid asset_account_code.' do
      adjustment.update(asset_account_code: 3000)

      api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }

      expect(adjustment.reload.state).to eq('pending')
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.adjustment.cannot_perform_accept_action')
    end

    it 'does not accept negative adjustment for sum bigger than member\'s balance' do
      adjustment.update(amount: -10000000.0)

      api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }

      expect(adjustment.reload.state).to eq('pending')
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.adjustment.user_insufficient_balance')
    end

    it 'does not update member\'s balance if it is lower than negative adjustment' do
      adjustment.update(amount: -10000000.0)

      expect {
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
      }.not_to change { member.get_account(adjustment.currency).balance }
    end

    context 'adjustment without member' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-402-") }

      it 'should accept adjustment' do
        adjustment.update(amount: -10000000.0)

        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
        }.to change { adjustment.reload.state }.to('accepted')
        .and change { Operations::Asset.count }.by(1)
        .and change { Operations::Expense.count }.by(1)

        expect(response).to be_successful
      end
    end

    context 'already accepted' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}").tap { |a| a.accept!(validator: member) } }

      it 'returns status and error' do
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }

        expect(response.code).to eq '422'
        expect(response).to include_api_error('admin.adjustment.cannot_perform_accept_action')
      end

      it 'does not udpate member\'s balance' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
        }.not_to change { member.accounts }
      end

      it 'does not create operations' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
        }.not_to change { Operations::Asset.count }
      end
    end

    context 'already rejected' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}").tap { |a| a.reject!(validator: member) } }

      it 'returns status and error' do
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }

        expect(response.code).to eq '422'
        expect(response).to include_api_error('admin.adjustment.cannot_perform_accept_action')
      end

      it 'does not udpate member\'s balance' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
        }.not_to change { member.accounts }
      end

      it 'does not create operations' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }
        }.not_to change { Operations::Asset.count }
      end
    end
  end

  describe 'POST /api/v2/admin/adjustments/action (reject)' do
    let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}") }

    it 'rejects adjustment' do
      expect {
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }
      }.to change { adjustment.reload.state }.to('rejected')
    end

    it 'does not create operations' do
      expect {
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }
      }.not_to change { Operations::Asset.count }
    end

    it 'does reject of negative amount' do
      adjustment.update(amount: -10000000.0)
      api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }

      expect(response.code).to eq '201'
    end

    context 'already rejected' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}").tap { |a| a.reject!(validator: member) } }

      it 'returns status and error' do
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :accept }

        expect(response.code).to eq '422'
        expect(response).to include_api_error('admin.adjustment.cannot_perform_accept_action')
      end

      it 'does not udpate member\'s balance' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }
        }.not_to change { member.accounts }
      end

      it 'does not create operations' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }
        }.not_to change { Operations::Asset.count }
      end
    end

    context 'already accepted' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}").tap { |a| a.accept!(validator: member) } }

      it 'returns status and error' do
        api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }

        expect(response.code).to eq '422'
        expect(response).to include_api_error('admin.adjustment.cannot_perform_reject_action')
      end

      it 'does not udpate member\'s balance' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }
        }.not_to change { member.accounts }
      end

      it 'does not create operations' do
        expect {
          api_post '/api/v2/admin/adjustments/action', token: token, params: { id: adjustment.id, action: :reject }
        }.not_to change { Operations::Asset.count }
      end
    end
  end
end
