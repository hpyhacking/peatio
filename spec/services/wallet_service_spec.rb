# encoding: UTF-8
# frozen_string_literal: true

describe WalletService do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  let(:deposit_wallet) { Wallet.find_by(currency: :eth, kind: :deposit) }
  let(:hot_wallet) { Wallet.find_by(currency: :eth, kind: :hot) }
  let(:warm_wallet) { Wallet.find_by(currency: :eth, kind: :warm) }

  describe 'spread deposit' do

    context 'Deposit divided in two wallets (hot and warm)' do

      let(:deposit) { create(:deposit, :deposit_eth, amount: 100) }

      let :hot_wallet_eth_getBalance_response do
        { result: '2b5e3af16b1880000' }.to_json
      end

      let :warm_wallet_eth_getBalance_response do
        { result: '0' }.to_json
      end

      let :hot_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ hot_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :warm_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ warm_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :spread_hash do
        {
          "0xb6a61c43DAe37c0890936D720DC42b5CBda990F9"=>0.5e2,
          "0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C"=>0.5e2
        }
      end

      subject { WalletService[deposit_wallet].send(:spread_deposit, deposit) }

      before do
        # Hot wallet balance = 50 eth
        stub_request(:post, hot_wallet.uri).with(body: hot_wallet_eth_getBalance_request).to_return(body: hot_wallet_eth_getBalance_response)
        # Warm wallet balance = 0 eth
        stub_request(:post, hot_wallet.uri).with(body: warm_wallet_eth_getBalance_request).to_return(body: warm_wallet_eth_getBalance_response)
      end
      it do
        # Deposit amount 100 eth
        # Collect 50 eth to Hot wallet and 50 eth to Warm wallet
        is_expected.to eq(spread_hash)
      end
    end

    context 'Deposit divided in two wallets and collect all remaining to last wallet(warm)' do

      let(:deposit) { create(:deposit, :deposit_eth, amount: 200) }

      let :hot_wallet_eth_getBalance_response do
        { result: '2b5e3af16b1880000' }.to_json
      end

      let :warm_wallet_eth_getBalance_response do
        { result: '0' }.to_json
      end

      let :hot_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ hot_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :warm_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ warm_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :spread_hash do
        {
          "0xb6a61c43DAe37c0890936D720DC42b5CBda990F9"=>0.5e2,
          "0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C"=>1.5e2
        }
      end

      subject { WalletService[deposit_wallet].send(:spread_deposit, deposit) }

      before do
        warm_wallet.update!(max_balance: 100)
        # Hot wallet balance = 50 eth
        stub_request(:post, hot_wallet.uri).with(body: hot_wallet_eth_getBalance_request).to_return(body: hot_wallet_eth_getBalance_response)
        # Warm wallet balance = 0 eth
        stub_request(:post, hot_wallet.uri).with(body: warm_wallet_eth_getBalance_request).to_return(body: warm_wallet_eth_getBalance_response)
      end
      it do
        # Deposit amount 200 eth
        # Collect 50 eth to Hot wallet and 150 eth to Warm wallet(last wallet)
        is_expected.to eq(spread_hash)
      end
    end

    context 'Deposit doesn\'t fit in any wallet' do
      let(:deposit) { create(:deposit, :deposit_eth, amount: 200) }

      let :hot_wallet_eth_getBalance_response do
        { result: '56bc75e2d63100000' }.to_json
      end

      let :warm_wallet_eth_getBalance_response do
        { result: '821ab0d4414980000' }.to_json
      end

      let :hot_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ hot_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :warm_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ warm_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :spread_hash do
        {
          "0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C"=>2e2
        }
      end

      subject { WalletService[deposit_wallet].send(:spread_deposit, deposit) }

      before do
        hot_wallet.update!(max_balance: 100)
        warm_wallet.update!(max_balance: 150)
        # Hot wallet balance = 100 eth
        stub_request(:post, hot_wallet.uri).with(body: hot_wallet_eth_getBalance_request).to_return(body: hot_wallet_eth_getBalance_response)
        # Warm wallet balance = 150 eth
        stub_request(:post, hot_wallet.uri).with(body: warm_wallet_eth_getBalance_request).to_return(body: warm_wallet_eth_getBalance_response)
      end

      it do
        # Deposit amount 200 eth
        # Collect all deposit to last wallet
        is_expected.to eq(spread_hash)
      end
    end

    context 'Intermediate amount is less than min collection amount in hot wallet' do
      let(:deposit) { create(:deposit, :deposit_eth, amount: 100) }

      let :hot_wallet_eth_getBalance_response do
        { result: '35ab028ac154b80000' }.to_json
      end

      let :warm_wallet_eth_getBalance_response do
        { result: '0' }.to_json
      end

      let :hot_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ hot_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :warm_wallet_eth_getBalance_request do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ warm_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :spread_hash do
        {
          "0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C"=>0.1e3
        }
      end

      subject { WalletService[deposit_wallet].send(:spread_deposit, deposit) }

      before do
        hot_wallet.update!(max_balance: 100)
        warm_wallet.update!(max_balance: 200)
        deposit.currency.update!(min_deposit_amount: 2)
        # Hot wallet balance = 99 eth
        stub_request(:post, hot_wallet.uri).with(body: hot_wallet_eth_getBalance_request).to_return(body: hot_wallet_eth_getBalance_response)
        # Warm wallet balance = 0 eth
        stub_request(:post, hot_wallet.uri).with(body: warm_wallet_eth_getBalance_request).to_return(body: warm_wallet_eth_getBalance_response)
      end

      it do
        # Deposit amount 100 eth
        # Collect all deposit to warm wallet
        is_expected.to eq(spread_hash)
      end
    end
  end
end
