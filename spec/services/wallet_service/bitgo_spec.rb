# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Bitgo do
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  let(:deposit) { create(:deposit_btc) }
  let(:deposit_wallet) { Wallet.find_by(currency: :btc, kind: :deposit) }
  let(:hot_wallet) { Wallet.find_by(currency: :btc, kind: :hot) }
  let(:wallet_client) { WalletClient[deposit_wallet] }
  let(:withdraw) { create(:btc_withdraw) }

  before do
    [deposit_wallet, hot_wallet].each do |wallet|
      wallet.update! \
      gateway:                     'bitgo',
      bitgo_test_net:              true,
      bitgo_wallet_id:             '5a7d9f52ba1923b107b80baabe0c3574',
      address:                     '2MtmgqDM5Gb91dAo1cUHpx9fdh1xgD7L1Xb',
      bitgo_wallet_passphrase:     'secret',
      bitgo_rest_api_root:         'http://127.0.0.1:3080/api/v2',
      bitgo_rest_api_access_token: 'v2x0b53e612518e5ea625eb3c24175438b37f56bc1f82e9c9ba3b038c91b0c72e67'
    end
  end

  def request_headers(wallet)
    { Accept:        'application/json',
      Authorization: 'Bearer ' + wallet.bitgo_rest_api_access_token }
  end

  def response_headers
    { 'Content-Type'  => 'application/json' }
  end

  describe '#create_address' do
    subject { WalletService[deposit_wallet].create_address(options) }

    before do
      stub_request(request_method, deposit_wallet.bitgo_rest_api_root + request_path)
          .with(body: request_body, headers: request_headers(deposit_wallet))
          .to_return(status: 200, body: response_body, headers: response_headers)
    end

    let(:request_body) { {} }
    let(:response_body) { '{"id":"5acb44423a713ade07b42b0140f91a96","address":"2MySruptM4SgZF49KSc3x5KyxAW61ghyvtc"}' }

    context 'when BitGo address ID is provided' do
      let(:options) { {} }
      let(:request_method) { :post }
      let(:request_path) { '/tbtc/wallet/' + deposit_wallet.bitgo_wallet_id + '/address' }

      it { is_expected.to eq(address: '2MySruptM4SgZF49KSc3x5KyxAW61ghyvtc', bitgo_address_id: '5acb44423a713ade07b42b0140f91a96') }
    end

    context 'when BitGo address ID is provided' do
      let(:request_path) { '/tbtc/wallet/' + deposit_wallet.bitgo_wallet_id + '/address/5acb44423a713ade07b42b0140f91a96' }
      let(:request_method) { :get }
      let(:options) { { address_id: '5acb44423a713ade07b42b0140f91a96' } }

      it { is_expected.to eq(address: '2MySruptM4SgZF49KSc3x5KyxAW61ghyvtc') }
    end
  end

  describe '#collect_deposit!' do
    subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

    let(:options) { {} }
    let(:request_method) { :post }
    let(:request_path) { '/tbtc/wallet/' + deposit_wallet.bitgo_wallet_id + '/tx/build' }
    let(:request_body) {{recipients:[{address: hot_wallet.address, amount: "#{wallet_client.convert_to_base_unit!(deposit.amount)}" }]} }
    let(:response_body) {'{"feeInfo": {"fee": 3037}}'}

    let(:set_tx_request_path) { '/tbtc/wallet/' + deposit_wallet.bitgo_wallet_id + '/sendcoins' }
    let(:set_tx_request_body) do
      { address: hot_wallet.address,
        amount: "#{(wallet_client.convert_to_base_unit!(deposit.amount)-3037).to_i}",
        walletPassphrase: deposit_wallet.bitgo_wallet_passphrase
      }
    end
    let(:set_tx_response_body) {'{"txid": "dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3" }'}

    before do
      # stub build_raw_transaction request
      stub_request(request_method, deposit_wallet.bitgo_rest_api_root + request_path)
          .with(body: request_body, headers: request_headers(deposit_wallet))
          .to_return(status: 200, body: response_body, headers: response_headers)

      # stub create_withdrawal request
      stub_request(request_method, deposit_wallet.bitgo_rest_api_root + set_tx_request_path)
          .with(body: set_tx_request_body, headers: request_headers(deposit_wallet))
          .to_return(status: 200, body: set_tx_response_body, headers: response_headers)
    end

    it { is_expected.to eq('dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3') }
  end

  describe '#build_withdrawal!' do
    subject { WalletService[hot_wallet].build_withdrawal!(withdraw) }

    let(:options) { {} }
    let(:request_method) { :post }
    let(:request_path) { '/tbtc/wallet/' + hot_wallet.bitgo_wallet_id + '/sendcoins' }
    let(:request_body) do
      { address: withdraw.rid,
        amount: "#{(wallet_client.convert_to_base_unit!(withdraw.amount)).to_i}",
        walletPassphrase: hot_wallet.bitgo_wallet_passphrase
      }
    end
    let(:response_body) {'{"txid": "dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3" }'}

    before do
      stub_request(request_method, hot_wallet.bitgo_rest_api_root + request_path)
          .with(body: request_body, headers: request_headers(hot_wallet))
          .to_return(status: 200, body: response_body, headers: response_headers)
    end

    it { is_expected.to eq('dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3') }
  end
end
