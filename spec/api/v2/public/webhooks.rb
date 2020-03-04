# frozen_string_literal: true

describe API::V2::Public::Webhooks, type: :request do
  describe 'GET /trading_fees' do

    let(:member) { create(:member) }

    let(:transaction) do
      Peatio::Transaction.new(
        currency_id: :eth,
        hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
        amount: 0.5,
        to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
        block_number: 16880960,
        txout: 0,
        status: :success
      )
    end

    let(:invlaid_transaction) do
      Peatio::Transaction.new(
        currency_id: :eth,
        hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
        amount: 0.5,
        to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b85',
        block_number: 16880960,
        txout: 0
      )
    end

    let!(:wallet) { create(:wallet, :eth_deposit, name: 'Bitgo Deposit',
                          gateway: :bitgo, settings: 
                          { uri: 'http://localhost',
                            secret: 'changeme',
                            bitgo_wallet_id: '5e4d43680f39a6710435b74edba4e2c2',
                            bitgo_access_token: 'changeme',
                            bitgo_test_net: false }) }

    let(:request_body) {
      { 'event' => 'deposit',
        'id' => '5e539be5e6715b2006c7bfa6278aa3f4',
        'type' => 'transfer',
        'wallet' => '5e4d43680f39a6710435b74edba4e2c2',
        'url' => 'http://localhost.com',
        'hash' => '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
        'coin' => 'eth',
        'transfer' => '5e4e824894d4902c060f20c28b161fa8',
        'state' => 'new',
        'simulation' => 'true',
        'retries' => '0',
        'webhook' => '5e5399ddda65833f06cd53429bcbca83',
        'updatedAt' => '2020-02-24T09:48:21.795Z',
        'version' => '2' }
    }


    context 'nonexistent wallet' do
      let(:request_body) {
        { 'event' => 'deposit',
          'id' => '5e539be5e6715b2006c7bfa6278aa3f4',
          'type' => 'transfer',
          'wallet' => 'changeme',
          'url' => 'http://localhost.com',
          'hash' => '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
          'coin' => 'eth',
          'transfer' => '5e4e824894d4902c060f20c28b161fa8',
          'state' => 'new',
          'simulation' => 'true',
          'retries' => '0',
          'webhook' => '5e5399ddda65833f06cd53429bcbca83',
          'updatedAt' => '2020-02-24T09:48:21.795Z',
          'version' => '2' }
      }


      it 'doesnt create deposit and return 200' do
        expect do
          api_post '/api/v2/public/webhooks/deposit', params: request_body

          expect(response.status).to eq 200
        end.not_to change { Deposit.count }
      end
    end

    context 'valid webhook callback' do 

      before do
        member.get_account(:eth).payment_addresses.create(currency_id: :eth, address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84')
        WalletService.any_instance.stubs(:trigger_webhook_event).with(request_body).returns({ transfers: [transaction] })
      end

      it 'creates new deposit' do
        api_post '/api/v2/public/webhooks/deposit', params: request_body

        expect(response.status).to eq 200
        expect(Deposit.last.txid).to eq('0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac')
      end

      context 'process second time' do

        it 'doesnt create deposit for same transfer' do
          api_post '/api/v2/public/webhooks/deposit', params: request_body
          expect do
            api_post '/api/v2/public/webhooks/deposit', params: request_body

            expect(response.status).to eq 200
            expect(Deposit.last.txid).to eq('0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac')
          end.not_to change { Deposit.count }
        end
      end

      context 'process undefined transfer' do

        before do
          WalletService.any_instance.stubs(:trigger_webhook_event).with(request_body).returns({ transfers: [invlaid_transaction] })
        end

        it 'doesnt create deposit and return 200' do
          expect do
            api_post '/api/v2/public/webhooks/deposit', params: request_body

            expect(response.status).to eq 200
          end.not_to change { Deposit.count }
        end
      end
    end

    context 'adapter raises error invalid' do

      before do
        member.get_account(:eth).payment_addresses.create(currency_id: :eth, address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84')
        WalletService.any_instance.stubs(:trigger_webhook_event).with(request_body).raises(Peatio::Wallet::ClientError.new('something went wrong'))
      end

      it 'returns error' do
        api_post '/api/v2/public/webhooks/deposit', params: request_body
        expect(response.status).to eq 422
        expect(response).to include_api_error('public.webhook.cannot_perfom_transfer')
      end
    end
  end
end
