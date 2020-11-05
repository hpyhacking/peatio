# frozen_string_literal: true

describe API::V2::Account::Stats, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  before do
    Ability.stubs(:user_permissions).returns({'member'=>{'read'=>['StatsMemberPnl']}})
  end

  describe 'GET /api/v2/account/stats/pnl' do
    let!(:eth) { Currency.find('eth') }
    let!(:btc) { Currency.find('btc') }
    let!(:pnl1) { create(:stats_member_pnl, pnl_currency_id: eth.id, currency_id: btc.id,
                               total_credit: 0.1, total_credit_fees: 0.01, total_debit_fees: 0.02, total_credit_value: 0.3, total_debit: 0.2,
                               total_debit_value: 10.0, average_balance_price: 0.42, member: member)}

    let!(:pnl2) { create(:stats_member_pnl, pnl_currency_id: btc.id, currency_id: eth.id,
                                total_credit: 0.1, total_credit_fees: 0.01, total_debit_fees: 0.02, total_credit_value: 0.3, total_debit: 0.2,
                                total_debit_value: 10.0, average_balance_price: 0.21, member: member)}

    it 'returns all user pnls for all pnl currencies' do
      api_get '/api/v2/account/stats/pnl', token: token

      expect(response).to be_successful

      expect(response_body.count).to eq 2
      expect(response_body[0]['currency']).to eq(pnl1.currency_id)
      expect(response_body[0]['pnl_currency']).to eq(pnl1.pnl_currency_id)
      expect(response_body[0]['total_credit'].to_f).to eq(pnl1.total_credit)
      expect(response_body[0]['total_credit_value'].to_f).to eq(pnl1.total_credit_value)
      expect(response_body[0]['total_debit'].to_f).to eq(pnl1.total_debit)
      expect(response_body[0]['total_debit_value'].to_f).to eq(pnl1.total_debit_value)
      expect(response_body[0]['average_buy_price'].to_f.round(9)).to eq( (pnl1.total_credit_value / (pnl1.total_credit)).to_f)
      expect(response_body[0]['average_sell_price'].to_f.round(9)).to eq(pnl1.total_debit_value / (pnl1.total_debit))
      expect(response_body[0]['average_balance_price'].to_f).to eq(0.42)

      expect(response_body[1]['currency']).to eq(pnl2.currency_id)
      expect(response_body[1]['pnl_currency']).to eq(pnl2.pnl_currency_id)
      expect(response_body[1]['total_credit'].to_f).to eq(pnl2.total_credit)
      expect(response_body[1]['total_credit_value'].to_f).to eq(pnl2.total_credit_value)
      expect(response_body[1]['total_debit'].to_f).to eq(pnl2.total_debit)
      expect(response_body[1]['total_debit_value'].to_f).to eq(pnl2.total_debit_value)
      expect(response_body[1]['average_buy_price'].to_f.round(9)).to eq( (pnl2.total_credit_value / (pnl2.total_credit)).to_f)
      expect(response_body[1]['average_sell_price'].to_f.round(9)).to eq(pnl2.total_debit_value / (pnl2.total_debit))
      expect(response_body[1]['average_balance_price'].to_f).to eq(0.21)
    end

    it 'returns user pnls for pnl currency eth' do
      api_get '/api/v2/account/stats/pnl?pnl_currency=eth', token: token

      expect(response).to be_successful

      expect(response_body.count).to eq 1
      expect(response_body[0]['currency']).to eq(pnl1.currency_id)
      expect(response_body[0]['pnl_currency']).to eq(pnl1.pnl_currency_id)
      expect(response_body[0]['total_credit'].to_f).to eq(pnl1.total_credit)
      expect(response_body[0]['total_credit_value'].to_f).to eq(pnl1.total_credit_value)
      expect(response_body[0]['total_debit'].to_f).to eq(pnl1.total_debit)
      expect(response_body[0]['total_debit_value'].to_f).to eq(pnl1.total_debit_value)
      expect(response_body[0]['average_buy_price'].to_f.round(9)).to eq( (pnl1.total_credit_value / (pnl1.total_credit)).to_f)
      expect(response_body[0]['average_sell_price'].to_f.round(9)).to eq(pnl1.total_debit_value / (pnl1.total_debit))
      expect(response_body[0]['average_balance_price'].to_f).to eq(0.42)
    end

    context 'avarage sell price equal to 0' do
      let!(:usd) { Currency.find('usd') }
      let!(:pnl) { create(:stats_member_pnl, pnl_currency_id: usd.id, currency_id: btc.id,
                                  total_credit: 0.1, total_credit_fees: 0.01, total_debit_fees: 0.0, total_credit_value: 0.3, total_debit: 0.0,
                                  total_debit_value: 0.0, average_balance_price: 0.12, member: member)}

      it 'return user pnl with zero avarage sell price' do
        api_get '/api/v2/account/stats/pnl?pnl_currency=usd', token: token

        expect(response).to be_successful

        expect(response_body.count).to eq 1
        expect(response_body[0]['currency']).to eq(pnl.currency_id)
        expect(response_body[0]['pnl_currency']).to eq(pnl.pnl_currency_id)
        expect(response_body[0]['total_credit'].to_f).to eq(pnl.total_credit)
        expect(response_body[0]['total_credit_value'].to_f).to eq(pnl.total_credit_value)
        expect(response_body[0]['total_debit'].to_f).to eq(pnl.total_debit)
        expect(response_body[0]['total_debit_value'].to_f).to eq(pnl.total_debit_value)
        expect(response_body[0]['average_buy_price'].to_f.round(9)).to eq( (pnl.total_credit_value / (pnl.total_credit)).to_f)
        expect(response_body[0]['average_sell_price'].to_f.round(9)).to eq 0
        expect(response_body[0]['average_balance_price'].to_f).to eq(0.12)
      end
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get '/api/v2/account/stats/pnl?pnl_currency=usd', token: token

        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end
end
