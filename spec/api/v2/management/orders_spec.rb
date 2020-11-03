# frozen_string_literal: true

describe API::V2::Management::Orders, type: :request do
  let(:member1) { create(:member, :level_3) }
  let(:member2) { create(:member, :level_3) }
  let(:signers) { %i[alex jeff] }
  let!(:finex_engine) { create(:engine, driver: 'finex-spot') }

  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_orders: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_orders: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }

    Market.find('btceth').update!(engine: finex_engine)
  end

  describe 'POST /api/v2/management/orders' do
    before do
      create(:order_bid, :btcusd, member: member1, state: Order::CANCEL)
      create(:order_ask, :btcusd, member: member1, state: Order::WAIT)
      create(:order_ask, :btceth, member: member1, state: Order::DONE)
      create(:order_bid, :btcusd, member: member2, state: Order::CANCEL)
      create(:order_ask, :btcusd, member: member2, state: Order::WAIT)
      create(:order_ask, :btceth, member: member2, state: Order::DONE)
    end

    def request
      post_json '/api/v2/management/orders', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }

    it 'returns all orders on the platform' do
      request

      expect(response).to have_http_status 200
      expect(response_body.count).to eq(Order.count)
    end

    context 'by member' do
      let(:data) do
        {
          uid: member1.uid
        }
      end

      it 'returns only member orders' do
        request

        expect(response).to have_http_status 200
        expect(response_body.pluck('member_id').uniq).to eq([member1.id])
      end
    end

    context 'by member, market, state and order type' do
      let(:data) do
        {
          uid: member1.uid,
          market: 'btcusd',
          state: 'wait',
          ord_type: 'limit'
        }
      end

      it 'returns only member orders on specific market with specific state and order type' do
        request

        expect(response).to have_http_status 200
        expect(response_body.pluck('member_id').uniq).to eq([member1.id])
        expect(response_body.pluck('state').uniq).to eq(['wait'])
        expect(response_body.pluck('market').uniq).to eq(['btcusd'])
        expect(response_body.pluck('ord_type').uniq).to eq(['limit'])
      end
    end

    context 'invalid params' do
      context 'member_uid' do
        it 'returns status 422 and error' do
          data[:uid] = 'invalid_uid'
          request

          expect(response).to have_http_status(422)
        end
      end

      context 'market' do
        it 'returns status 422 and error' do
          data[:market] = 'invalid_market'
          request

          expect(response).to have_http_status(422)
        end
      end

      context 'state' do
        it 'returns status 422 and error' do
          data[:state] = 'invalid_state'
          request

          expect(response).to have_http_status(422)
        end
      end

      context 'ord_type' do
        it 'returns status 422 and error' do
          data[:ord_type] = 'invalid_ord_type'
          request

          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe 'POST /api/v2/management/orders/:id/cancel' do
    let!(:peatio_order) { create(:order_ask, :btcusd, member: member1, state: Order::WAIT) }
    let!(:third_party_order) { create(:order_ask, :btceth, member: member1, state: Order::WAIT) }

    def request(order_id)
      post_json "/api/v2/management/orders/#{order_id}/cancel", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }

    it 'cancels an order on peatio market' do
      AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: peatio_order.to_matching_attributes)
      AMQP::Queue.expects(:publish).with(finex_engine.driver, data: peatio_order.as_json_for_third_party, type: 3).never
      request(peatio_order.id)
      expect(response).to have_http_status 200
    end

    context 'third party order cancel' do
      it 'cancel an order on third party market' do
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: third_party_order.to_matching_attributes).never
        AMQP::Queue.expects(:publish).with(finex_engine.driver, data: third_party_order.as_json_for_third_party, type: 3)

        request(third_party_order.id)
        expect(response).to have_http_status 200
      end
    end

    context 'invalid params' do
      it 'returns status 404 and error' do
        request(0)

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v2/management/orders/cancel' do
    let!(:member1_peatio_order) {  create(:order_ask, :btcusd, member: member1, state: Order::WAIT) }
    let!(:member2_peatio_order) {  create(:order_ask, :btcusd, member: member2, state: Order::WAIT) }
    let!(:member1_third_party_order) {  create(:order_ask, :btceth, member: member1, state: Order::WAIT) }
    let!(:member2_third_party_order) {  create(:order_ask, :btceth, member: member2, state: Order::WAIT) }

    def request
      post_json '/api/v2/management/orders/cancel', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }

    context 'peatio order cancel' do

      it 'cancels the orders on peatio market' do
        data[:market] = 'btcusd'

        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: member1_peatio_order.to_matching_attributes)
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: member2_peatio_order.to_matching_attributes)
        AMQP::Queue.expects(:publish).with(finex_engine.driver, data: { market_id: 'btcusd' }, type: 4).never

        request
        expect(response).to have_http_status 204
      end

      it 'cancels the orders on peatio market' do
        data[:market] = 'btcusd'
        data[:uid] = member1.uid

        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: member1_peatio_order.to_matching_attributes)
        AMQP::Queue.expects(:publish).with(finex_engine.driver, data: { market_id: 'btcusd' }, type: 4).never

        request
        expect(response).to have_http_status 204
      end

    end

    context 'third party orders cancel' do
      it 'cancels the orders on third party market' do
        data[:market] = 'btceth'

        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: member1_peatio_order.to_matching_attributes).never
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: member2_peatio_order.to_matching_attributes).never
        AMQP::Queue.expects(:publish).with(finex_engine.driver, data: { market_id: 'btceth' }, type: 4)

        request
        expect(response).to have_http_status 204
      end

      it 'cancels the orders on third party market' do
        data[:market] = 'btceth'
        data[:uid] = member1.uid

        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: member1_peatio_order.to_matching_attributes).never
        AMQP::Queue.expects(:publish).with(finex_engine.driver, data: { market_id: 'btceth', member_uid: member1.uid }, type: 4)

        request
        expect(response).to have_http_status 204
      end
    end

    context 'invalid params' do
      context 'invalid market' do
        it 'returns status 422 and error' do
          data[:market] = 'btcbtc'
          request

          expect(response).to have_http_status(422)
        end
      end

      context 'invalid uid' do
        it 'returns status 422 and error' do
          data[:market] = 'btceth'
          data[:uid] = 'invalid_uid'
          request

          expect(response).to have_http_status(422)
        end
      end
    end
  end
end
