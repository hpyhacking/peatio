# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Bitcoind do
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'WalletService::Bitcoind' do

    let(:deposit) { create(:deposit, :deposit_btc, amount: 10) }
    let(:withdraw) { create(:btc_withdraw) }
    let(:deposit_wallet) { Wallet.find_by(gateway: :bitcoind, kind: :deposit) }
    let(:hot_wallet) { Wallet.find_by(gateway: :bitcoind, kind: :hot) }

    context '#create_address' do
      subject { WalletService[deposit_wallet].create_address }

      let(:newaddress) { '2N7r9zKXkypzqtXfWkKfs3uZqKbJUhdK6JE' }
      let :getnewaddress_request do
        { jsonrpc: '1.0',
          method: 'getnewaddress',
          params: []
        }.to_json
      end

      let :getnewaddress_response do
        { result: newaddress }.to_json
      end

      before do
        stub_request(:post, deposit_wallet.uri).with(body: getnewaddress_request).to_return(body: getnewaddress_response)
      end

      it { is_expected.to eq(address: newaddress) }
    end

    context '#collect_deposit!' do
      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      let(:txid) { 'dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3' }

      let :listunspent_response do
        { result: '0' }.to_json
      end

      let :listunspent_request do
        {
            jsonrpc:  '1.0',
            method:   'listunspent',
            params:   [1, 10000000, ['3NwYr8JxjHG2MBkgdBiHCxStSWDzyjS5U8']],
        }.to_json
      end

      let :sendtoaddress_request do
        { jsonrpc: '1.0',
          method: 'sendtoaddress',
          params: [hot_wallet.address, deposit.amount, '', '', true]
        }.to_json
      end

      let :sendtoaddress_response do
        { result: txid }.to_json
      end

      before do
        stub_request(:post, hot_wallet.uri).with(body: listunspent_request).to_return(body: listunspent_response)
        stub_request(:post, deposit_wallet.uri).with(body: sendtoaddress_request).to_return(body: sendtoaddress_response)
      end

      it { is_expected.to eq([txid]) }
    end

    context '#build_withdrawal!' do
      subject { WalletService[hot_wallet].build_withdrawal!(withdraw) }

      let(:txid) { 'dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3' }

      let :sendtoaddress_request do
        { jsonrpc: '1.0',
          method: 'sendtoaddress',
          params: [withdraw.rid, withdraw.amount, '', '', false]
        }.to_json
      end

      let :sendtoaddress_response do
        { result: txid }.to_json
      end

      before do
        stub_request(:post, hot_wallet.uri).with(body: sendtoaddress_request).to_return(body: sendtoaddress_response)
      end

      it { is_expected.to eq(txid) }
    end
  end
end
