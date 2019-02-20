# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Parity do
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  let(:deposit_wallet) { Wallet.find_by(currency: :eth, kind: :deposit, gateway: :parity) }
  let(:hot_wallet) { Wallet.find_by(currency: :eth, kind: :hot, gateway: :parity) }
  let(:warm_wallet) { Wallet.find_by(currency: :eth, kind: :warm, gateway: :parity) }
  let(:fee_wallet) { Wallet.find_by(currency: 'eth', kind: 'fee', gateway: :parity) }
  let(:eth_options) { { gas_limit: 21_000, gas_price: 1_000_000_000 } }

  describe '#create_address' do
    subject { WalletService[deposit_wallet].create_address }

    let :personal_newAccount_request do
      { jsonrpc: '2.0',
        id:      1,
        method:  'personal_newAccount',
        params:  %w[ pass@word ]
      }.to_json
    end

    let :personal_newAccount_response do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x42eb768f2244c8811c63729a21a3569731535f06'
      }.to_json
    end

    before do
      Passgen.stubs(:generate).returns('pass@word')
      stub_request(:post, deposit_wallet.uri ).with(body: personal_newAccount_request).to_return(body: personal_newAccount_response)
    end

    it { is_expected.to eq(address: '0x42eb768f2244c8811c63729a21a3569731535f06', secret: 'pass@word') }
  end

  describe '#collect_deposit!' do

      let(:deposit) { create(:deposit, :deposit_eth, amount: 10) }
      let(:eth_payment_address) { deposit.account.payment_address }
      let(:issuer) { { address: eth_payment_address.address.downcase, secret: eth_payment_address.secret } }

      let!(:payment_address) do
        create(:eth_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa', secret: 'changeme'})
      end

      context 'Collect eth deposit to hot wallet' do

        let(:deposit_wallet_address) { deposit_wallet.address.downcase }
        let(:hot_wallet_address) { hot_wallet.address.downcase }
        let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

        let :eth_getBalance_request do
          { jsonrpc:  '2.0',
            id:       1,
            method:   'eth_getBalance',
            params:   [hot_wallet_address, 'latest'] }.to_json
        end

        let :eth_getBalance_response do
          { id: 1,
            jsonrpc: '2.0',
            result: '0x0' }.to_json
        end

        let :personal_sendTransaction_request do
          { jsonrpc: '2.0',
            id:       1,
            method:  'personal_sendTransaction',
            params:
              [
                {
                  from:  issuer[:address],
                  to:    hot_wallet_address,
                  value: '0x' + (deposit.amount_to_base_unit! - eth_options[:gas_limit] * eth_options[:gas_price]).to_s(16),
                  gas:   '0x' + eth_options[:gas_limit].to_s(16),
                  gasPrice: '0x' + eth_options[:gas_price].to_s(16),
                },
                issuer[:secret]
              ] }.to_json
        end

        let :personal_sendTransaction_response do
          { jsonrpc: '2.0',
            id:      2,
            result:  txid }.to_json
        end

        subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

        before do
          stub_request(:post, hot_wallet.uri).with(body: eth_getBalance_request).to_return(body: eth_getBalance_response)
          stub_request(:post, deposit_wallet.uri).with(body: personal_sendTransaction_request).to_return(body: personal_sendTransaction_response)
        end

        it do
          # Transaction to Hot wallet with all deposit amount
          is_expected.to eq([txid])
        end
      end

    context 'Collect RING deposit to hot wallet' do
      let(:deposit) { create(:deposit, :deposit_ring, amount: 10) }
      let(:ring_payment_address) { deposit.account.payment_address }

      let(:deposit_wallet) { Wallet.find_by(currency: :ring, kind: :deposit) }
      let(:hot_wallet) { Wallet.find_by(currency: :ring, kind: :hot) }

      let(:issuer) { { address: ring_payment_address.address, secret: ring_payment_address.secret } }
      let(:recipient) { { address: hot_wallet.address } }

      let!(:payment_address) do
        create(:ring_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa', secret: 'changeme'})
      end

      let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

      let :eth_call_request do
        {
          "jsonrpc":"2.0",
          "id":1,
          "method":"eth_call",
          "params":
            [
              {
                "to":"0xf8720eb6ad4a530cccb696043a0d10831e2ff60e",
                "data":"0x70a0823100000000000000000000000023236af7d03c4b0720f709593f5ace0ea92e77cf"
              },
              "latest"
            ]
        }.to_json
      end

      let :eth_call_response do
        { id: 2,
          jsonrpc: '2.0',
          result: '0x' }.to_json
      end

      let :personal_sendTransaction_request do
        { jsonrpc: '2.0',
          id:      1,
          method:  'personal_sendTransaction',
          params:
            [
              {
                from:  issuer[:address],
                to:    '0xf8720eb6ad4a530cccb696043a0d10831e2ff60e',
                data:  '0xa9059cbb00000000000000000000000023236af7d03c4b0720f709593f5ace0ea92e77cf0000000000000000000000000000000000000000000000000000000000989680',
                gas:   '0x15f90',
                gasPrice: '0x3b9aca00'
              }, issuer[:secret]
            ] }.to_json
      end

      let :personal_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      1,
          result:  txid }.to_json
      end

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      before do
        stub_request(:post, hot_wallet.uri).with(body: eth_call_request).to_return(body: eth_call_response)
        stub_request(:post, deposit_wallet.uri).with(body: personal_sendTransaction_request).to_return(body: personal_sendTransaction_response)
      end

      it do
        is_expected.to eq([txid])
      end
    end
  end

  describe 'create_withdrawal!' do
    let(:issuer) { { address: hot_wallet.address.downcase, secret: hot_wallet.secret } }
    let(:recipient) { { address: withdraw.rid.downcase } }

    context 'ETH Withdrawal' do
      let(:withdraw) { create(:eth_withdraw, rid: '0x85h43d8a49eeb85d32cf465507dd71d507100c1') }

      let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

      let :personal_sendTransaction_request do
        { jsonrpc: '2.0',
          id:      1,
          method:  'personal_sendTransaction',
          params:
            [
              {
                from:     issuer[:address],
                to:       recipient[:address],
                value:    '0x8a6e51a672858000',
                gas:      '0x5208',
                gasPrice: '0x3b9aca00'
              }, issuer[:secret]
            ]
        }.to_json
      end

      let :personal_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      1,
          result:  txid
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw)}

      before do
        stub_request(:post, 'http://127.0.0.1:8545/').with(body: personal_sendTransaction_request).to_return(body: personal_sendTransaction_response)
      end

      it { is_expected.to eq(txid) }
    end

    context 'RING Withdrawal' do
      let(:withdraw) { create(:ring_withdraw, rid: '0x85h43d8a49eeb85d32cf465507dd71d507100c1') }
      let(:hot_wallet) { Wallet.find_by(currency: :ring, kind: :hot) }
      let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

      let :personal_sendTransaction_request do
        { jsonrpc: '2.0',
          id:      1,
          method:  'personal_sendTransaction',
          params:
            [
              {
                from:   issuer[:address].downcase,
                to:     '0xf8720eb6ad4a530cccb696043a0d10831e2ff60e',
                data:   '0xa9059cbb000000000000000000000000085h43d8a49eeb85d32cf465507dd71d507100c100000000000000000000000000000000000000000000000000000000009834d8',
                gas:   '0x15f90',
                gasPrice: '0x3b9aca00'
              }, issuer[:secret]
            ]
        }.to_json
      end

      let :personal_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      1,
          result:  txid
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw)}

      before do
        stub_request(:post, 'http://127.0.0.1:8545/').with(body: personal_sendTransaction_request).to_return(body: personal_sendTransaction_response)
      end

      it { is_expected.to eq(txid) }
    end
  end

  describe 'deposit_collection_fees!' do
    let(:deposit) { create(:deposit, :deposit_ring, amount: 10) }
    let(:ring_payment_address) { deposit.account.payment_address }

    let(:issuer) { { address: fee_wallet.address.downcase, secret: fee_wallet.secret } }
    let(:recipient) { { address: ring_payment_address.address.downcase } }

    let!(:payment_address) do
      create(:ring_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa'})
    end

    let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

    let :personal_sendTransaction_request do
      { jsonrpc: '2.0',
        id:      1,
        method:  'personal_sendTransaction',
        params:
          [
            {
              from:  issuer[:address],
              to:    recipient[:address],
              value: '0x51dac207a000',
              gas:   '0x' + eth_options[:gas_limit].to_s(16),
              gasPrice: '0x' + eth_options[:gas_price].to_s(16)
            }, issuer[:secret]
          ]
      }.to_json
    end

    let :personal_sendTransaction_response do
      { jsonrpc: '2.0',
        id:      1,
        result:  txid
      }.to_json
    end

    subject { WalletService[deposit_wallet].deposit_collection_fees(deposit) }

    before do
      stub_request(:post, deposit_wallet.uri).with(body: personal_sendTransaction_request).to_return(body: personal_sendTransaction_response)
    end

    it do
      is_expected.to eq(txid)
    end
  end
end
