# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Beneficiaries, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member, :level_3) }
  let(:member_token) { jwt_for(level_3_member) }

  let!(:pending_beneficiaries_for_member) do
    create_list(:beneficiary, 2, member: member, state: :pending)
  end

  let!(:active_beneficiaries_for_member) do
    create_list(:beneficiary, 3, member: member, state: :active)
  end

  let!(:archived_beneficiaries_for_member) do
    create_list(:beneficiary, 2, member: member, state: :archived)
  end

  let!(:other_member_beneficiaries) do
    create_list(:beneficiary, 5)
  end

  let!(:fiat_beneficiary) {
    create(:beneficiary, state: :active, currency: Currency.find('usd'))
  }

  describe 'GET /api/v2/admin/beneficiaries' do
    let(:url) { '/api/v2/admin/beneficiaries' }

    it 'get all beneficiaries' do
      api_get url, token: token
      expect(response_body.count).to eq(Beneficiary.count)
    end

    context 'ordering' do
      it 'ascending by id' do
        api_get url, token: token, params: { order_by: 'id', ordering: 'asc' }

        expect(response_body.first['id']).to eq Beneficiary.first.id
      end

      it 'descending by id' do
        api_get url, token: token, params: { order_by: 'id', ordering: 'desc' }

        expect(response_body.first['id']).to eq Beneficiary.last.id
      end
    end

    context 'filtering' do
      it 'by member' do
        api_get url, token: token, params: { uid: member.uid }

        expect(response_body.count).to eq(member.beneficiaries.count)
      end

      it 'by state' do
        api_get url, token: token, params: { state: ['pending', 'archived'] }

        expect(response_body.count).to eq(Beneficiary.where(state: ['pending', 'archived']).count)
      end

      context 'by currency' do
        it 'by crypto currency' do
          api_get url, token: token, params: { currency: ['eth', 'btc'] }

          expect(response_body.count).to eq(Beneficiary.where(currency_id: ['eth', 'btc']).count)
        end

        it 'by fiat currency' do
          api_get url, token: token, params: { currency: 'usd' }

          expect(response_body.count).to eq(Beneficiary.where(currency_id: 'usd').count)
          expect(response_body.first['data']).to eq Beneficiary.where(currency_id: 'usd').last.data
        end
      end
    end

    context 'actions' do
      let(:url) { '/api/v2/admin/beneficiaries/actions' }

      it 'by archived' do
        api_post url, token: token, params: { action: 'archive', id: fiat_beneficiary.id }

        expect(response_body['data']).to eq fiat_beneficiary.data.with_indifferent_access
        expect(response_body['state']).to eq('archived')
      end
    end
  end
end
