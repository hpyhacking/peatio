# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Abilities, type: :request do
  describe 'GET /api/v2/admin/abilities' do
    context 'member role' do
      let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
      let(:token) { jwt_for(admin) }
      it 'get all roles and permissions' do
        api_get '/api/v2/admin/abilities', token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result).to eq(
          "manage" => ["Beneficiary", "Operations::Account", "Operations::Asset", "Operations::Expense", "Operations::Liability", "Operations::Revenue", "Engine", "Market", "Currency", "Blockchain", "Wallet", "TradingFee", "WithdrawLimit", "Adjustment", "Deposit", "Withdraw"],
          "read" => ["Trade", "Account", "PaymentAddress", "Member", "Order"],
          "update" => ["Order", "Member"],
        )
      end
    end

    context 'member role' do
      let(:member) { create(:member, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
      let(:token) { jwt_for(member) }
      it 'get all roles and permissions' do
        api_get '/api/v2/admin/abilities', token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result).to eq({})
      end
    end
  end
end
