# frozen_string_literal: true

describe API::V2::Management::PaymentAddress, type: :request do
  let(:member1) { create(:member, :level_3) }
  let(:member2) { create(:member, :level_3) }
  let(:signers) { %i[alex jeff] }

  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
    scopes: {
      write_payment_addresses: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
    }
  end

  describe 'POST /api/v2/management/deposit_address/new' do
    let(:data) { { currency: 'eth', blockchain_key: 'eth-rinkeby', uid: member1.uid } }
    let(:address) { 'qwerty' }

    def request
      post_json '/api/v2/management/deposit_address/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    before do
      WalletService.any_instance.stubs(:create_address!).returns({ address: address, secret: 'qwerty' })
    end

    it 'generates new address' do
      request
      expect(response_body).to eq({"address"=>address, "blockchain_key"=>data[:blockchain_key], "currencies"=>[data[:currency]], "remote"=>false, "state"=>"active", "uid"=>data[:uid]})
      expect(response).to have_http_status 200
    end

    context 'generates new address for btc' do
      it do
        data[:currency] = 'btc'
        data[:blockchain_key] = 'btc-testnet'
        request
        expect(response_body).to eq({"address"=>address, "blockchain_key"=>data[:blockchain_key], "currencies"=>[data[:currency]], "remote"=>false, "state"=>"active", "uid"=>data[:uid]})
        expect(response).to have_http_status 200
      end
    end

    context 'generates new address with specified remote value' do
      it do
        data[:remote] = true
        request
        expect(response_body).to eq({"address"=>address, "blockchain_key"=>data[:blockchain_key], "currencies"=>[data[:currency]], "remote"=>true, "state"=>"active", "uid"=>data[:uid]})
        expect(response).to have_http_status 200
      end
    end

    context 'missing required params' do
      context 'uid' do
        it do
          data.delete(:uid)
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/uid is missing/i)
        end
      end

      context 'currency' do
        it do
          data.delete(:currency)
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/currency is missing/i)
        end
      end
    end

    context 'non-existing params applied' do
      context 'uid' do
        it do
          data[:uid] = '123456'
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.payment_address.uid_doesnt_exist/i)
        end
      end

      context 'currency' do
        it do
          data[:currency] = 'uah'
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.payment_address.currency_doesnt_exist/i)
        end
      end

      context 'remote' do
        it do
          data[:remote] = 'remote'
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.payment_address.non_boolean_remote/i)
        end
      end
    end

    context 'wallet service raised an error' do
      before do
        WalletService.any_instance.stubs(:create_address!).raises(StandardError.new)
      end

      it do
        request
        expect(response.body).to match(/management.payment_address.failed_to_generate/i)
        expect(response).to have_http_status 422
      end
    end
  end
end
