# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Geth do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  let(:deposit_wallet) { Wallet.find_by(currency: :eth, kind: :deposit) }
  let(:hot_wallet) { Wallet.find_by(currency: :eth, kind: :hot) }
  let(:warm_wallet) { Wallet.find_by(currency: :eth, kind: :warm) }
  let(:fee_wallet) { Wallet.find_by(currency: 'eth', kind: 'fee') }

  let(:eth_options) { WalletService::Geth::DEFAULT_ETH_FEE }
  let(:erc20_options) { WalletService::Geth::DEFAULT_ERC20_FEE }

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
      create(:eth_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa'})
    end

    context 'Collect eth deposit to hot wallet' do

      let(:deposit_wallet_address) { deposit_wallet.address.downcase }
      let(:hot_wallet_address) { hot_wallet.address.downcase }
      let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

      let :eth_getBalance_request do
        { jsonrpc:  '2.0',
        id:       1,
        method:   'eth_getBalance',
        params:   [ hot_wallet_address, 'latest' ],
        }.to_json
      end

      let :eth_getBalance_response do
        { result: '0' }.to_json
      end

      let :eth_sendTransaction_request do
      { jsonrpc: '2.0',
        id:       1,
        method:  'eth_sendTransaction',
        params:
          [
            {
              from:  issuer[:address],
              to:    hot_wallet_address,
              value: '0x' + (deposit.amount_to_base_unit! - eth_options[:gas_limit] * eth_options[:gas_price]).to_s(16),
              gas:   '0x' + eth_options[:gas_limit].to_s(16),
              gasPrice: '0x' + eth_options[:gas_price].to_s(16)
            }
          ]
      }.to_json
      end

      let :eth_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      2,
          result:  txid
        }.to_json
      end

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      before do
        stub_request(:post, hot_wallet.uri).with(body: eth_getBalance_request).to_return(body: eth_getBalance_response)
        WalletClient[deposit_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, deposit_wallet.uri).with(body: eth_sendTransaction_request).to_return(body: eth_sendTransaction_response)
      end

      it do
        #Transaction to Hot wallet with all deposit amount
        is_expected.to eq([txid])
      end
    end

    context 'Collect TRST deposit to hot wallet' do
      let(:deposit) { create(:deposit, :deposit_trst, amount: 10) }
      let(:trst_payment_address) { deposit.account.payment_address }

      let(:deposit_wallet) { Wallet.find_by(currency: :trst, kind: :deposit) }
      let(:hot_wallet) { Wallet.find_by(currency: :trst, kind: :hot) }

      let(:issuer) { { address: trst_payment_address.address, secret: trst_payment_address.secret } }
      let(:recipient) { { address: hot_wallet.address } }

      let!(:payment_address) do
        create(:trst_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa'})
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
                "to":"0x87099add3bcc0821b5b151307c147215f839a110",
                "data":"0x70a08231000000000000000000000000b6a61c43dae37c0890936d720dc42b5cbda990f9"
              },
              "latest"
            ]
        }.to_json
      end

      let :eth_call_response do
        { result: '0' }.to_json
      end

      let :eth_sendTransaction_request do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:
            [
              {
                from:      issuer[:address],
                to:        '0x87099add3bcc0821b5b151307c147215f839a110',
                data:      '0xa9059cbb000000000000000000000000b6a61c43dae37c0890936d720dc42b5cbda990f90000000000000000000000000000000000000000000000000000000000989680',
                gas:       '0x' + erc20_options[:gas_limit].to_s(16),
                gasPrice:  '0x' + erc20_options[:gas_price].to_s(16)
              }
            ]
        }.to_json
      end

      let :eth_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      1,
          result:  txid
        }.to_json
      end

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      before do
        stub_request(:post, hot_wallet.uri).with(body: eth_call_request).to_return(body: eth_call_response)
        WalletClient[deposit_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, deposit_wallet.uri).with(body: eth_sendTransaction_request).to_return(body: eth_sendTransaction_response)
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

      let :eth_sendTransaction_request do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:
            [
              {
                from:  issuer[:address],
                to:    recipient[:address],
                value: '0x8a6e51a672858000',
                gas:   '0x' + eth_options[:gas_limit].to_s(16),
                gasPrice: '0x' + eth_options[:gas_price].to_s(16)
              }
            ]
        }.to_json
      end

      let :eth_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      1,
          result:  txid
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw)}

      before do
        WalletClient[hot_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, 'http://127.0.0.1:8545/').with(body: eth_sendTransaction_request).to_return(body: eth_sendTransaction_response)
      end

      it 'sends withdrawal' do
        is_expected.to eq(txid)
      end

      context 'custom gas_price and gas_fee' do
        let(:custom_eth_options) do
          { gas_limit: 2 * eth_options[:gas_limit],
            gas_price: 2 * eth_options[:gas_price] }
        end

        let :eth_sendTransaction_request do
          { jsonrpc: '2.0',
            id:      1,
            method:  'eth_sendTransaction',
            params:
              [
                {
                  from:  issuer[:address],
                  to:    recipient[:address],
                  value: '0x8a6e51a672858000',
                  gas:   '0x' + custom_eth_options[:gas_limit].to_s(16),
                  gasPrice: '0x' + custom_eth_options[:gas_price].to_s(16)
                }
              ]
          }.to_json
        end

        before do
          withdraw.currency.update(custom_eth_options)
        end

        it 'sends withdrawal' do
          is_expected.to eq(txid)
        end
      end
    end

    context 'TRST Withdrawal' do
      let(:withdraw) { create(:trst_withdraw, rid: '0x85h43d8a49eeb85d32cf465507dd71d507100c1') }
      let(:hot_wallet) { Wallet.find_by(currency: :trst, kind: :hot) }
      let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }


      let :eth_sendTransaction_request do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:
            [
              {
                from:   issuer[:address].downcase,
                to:     '0x87099add3bcc0821b5b151307c147215f839a110',
                data:   '0xa9059cbb000000000000000000000000085h43d8a49eeb85d32cf465507dd71d507100c100000000000000000000000000000000000000000000000000000000009834d8',
                gas:   '0x' + erc20_options[:gas_limit].to_s(16),
                gasPrice: '0x' + erc20_options[:gas_price].to_s(16)
              }
            ]
        }.to_json
      end

      let :eth_sendTransaction_response do
        { jsonrpc: '2.0',
          id:      1,
          result:  txid
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw)}

      before do
        WalletClient[hot_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, 'http://127.0.0.1:8545/').with(body: eth_sendTransaction_request).to_return(body: eth_sendTransaction_response)
      end

      it 'sends withdrawal and returns txid' do
        is_expected.to eq(txid)
      end

      context 'custom gas_price and gas_fee' do
        let(:custom_erc20_options) do
          { gas_limit: 2 * erc20_options[:gas_limit],
            gas_price: 2 * erc20_options[:gas_price] }
        end

        let :eth_sendTransaction_request do
          { jsonrpc: '2.0',
            id:      1,
            method:  'eth_sendTransaction',
            params:
              [
                {
                  from:   issuer[:address].downcase,
                  to:     '0x87099add3bcc0821b5b151307c147215f839a110',
                  data:   '0xa9059cbb000000000000000000000000085h43d8a49eeb85d32cf465507dd71d507100c100000000000000000000000000000000000000000000000000000000009834d8',
                  gas:   '0x' + custom_erc20_options[:gas_limit].to_s(16),
                  gasPrice: '0x' + custom_erc20_options[:gas_price].to_s(16)
                }
              ]
          }.to_json
        end

        before do
          withdraw.currency.update(custom_erc20_options)
        end

        it 'sends withdrawal' do
          is_expected.to eq(txid)
        end
      end
    end
  end

  describe 'deposit_collection_fees!' do
    let(:deposit) { create(:deposit, :deposit_trst, amount: 10) }
    let(:trst_payment_address) { deposit.account.payment_address }

    let(:issuer) { { address: fee_wallet.address.downcase, secret: fee_wallet.secret } }
    let(:recipient) { { address: trst_payment_address.address.downcase } }

    let(:collection_fees) { '0x' + (erc20_options[:gas_price] * erc20_options[:gas_limit]).to_s(16) }

    let!(:payment_address) do
      create(:trst_payment_address, { account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa' })
    end

    let(:txid) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }

    let :eth_sendTransaction_request do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_sendTransaction',
        params:
          [
            {
              from:  issuer[:address],
              to:    recipient[:address],
              value: collection_fees,
              gas:   '0x' + eth_options[:gas_limit].to_s(16),
              gasPrice: '0x' + eth_options[:gas_price].to_s(16)
            }
          ]
      }.to_json
    end

    let :eth_sendTransaction_response do
      { jsonrpc: '2.0',
        id:      1,
        result:  txid
      }.to_json
    end

    subject { WalletService[deposit_wallet].deposit_collection_fees(deposit) }

    before do
      WalletClient[deposit_wallet].class.any_instance.expects(:permit_transaction)
      stub_request(:post, deposit_wallet.uri).with(body: eth_sendTransaction_request).to_return(body: eth_sendTransaction_response)
    end

    it do
      is_expected.to eq(txid)
    end
  end
end
