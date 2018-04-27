describe CoinAPI::BitGo do
  let(:currency) { Currency.find_by_code!(:btc) }
  let(:client) { currency.api }

  before do
    currency.update! \
      api_client:                  'BitGo',
      bitgo_test_net:              true,
      bitgo_wallet_id:             '5a7d9f52ba1923b107b80baabe0c3574',
      bitgo_wallet_address:        '2MtmgqDM5Gb91dAo1cUHpx9fdh1xgD7L1Xb',
      bitgo_wallet_passphrase:     'secret',
      bitgo_rest_api_root:         'http://127.0.0.1:3080/api/v2',
      bitgo_rest_api_access_token: 'v2x0b53e612518e5ea625eb3c24175438b37f56bc1f82e9c9ba3b038c91b0c72e67'
  end

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  before do
    stub_request(request_method, currency.bitgo_rest_api_root + request_path)
      .with(body: request_body, headers: request_headers)
      .to_return(status: 200, body: response_body, headers: response_headers)
  end

  let :default_request_headers do
    { 'Accept'        => 'application/json',
      'Authorization' => 'Bearer ' + currency.bitgo_rest_api_access_token }
  end

  let :default_response_headers do
    { 'Content-Type'  => 'application/json' }
  end

  describe '#create_address!' do
    subject { client.create_address!(options) }

    let(:options) { {} }
    let(:request_path) { '/tbtc/wallet/' + currency.bitgo_wallet_id + '/address' }
    let(:request_method) { :post }
    let(:request_body) { nil }
    let(:request_headers) { default_request_headers }
    let(:response_headers) { default_response_headers }
    let(:response_body) { '{"id":"5acb44423a713ade07b42b0140f91a96","address":"2MySruptM4SgZF49KSc3x5KyxAW61ghyvtc","chain":10,"index":25278,"coin":"tbtc","wallet":"5a7d9f52ba1923b107b80baabe0c3574","coinSpecific":{"redeemScript":"0020e26a7cace11e649369e123bd1b41705e11112b50614af287db7c2e4bed4fc0c8","witnessScript":"5221035326e902af387358efa08235768b3a70a7a630f68ae031a2a043c9b5a20bcacd21020a33b1dfe30a73109bd7f9f7e9fd7b906b1ce3f28d682b87aa7f435a34ff8d5721030b610df9f6e209f7cec3da6c718861a7501f8eff46851235de7d4f7eebbbc19e53ae"}}' }

    it { is_expected.to eq(address: '2MySruptM4SgZF49KSc3x5KyxAW61ghyvtc', bitgo_address_id: '5acb44423a713ade07b42b0140f91a96') }

    context 'when address is not generated immediately' do
      let(:response_body) { '{"id":"5acb44423a713ade07b42b0140f91a96","chain":10,"index":25278,"coin":"tbtc","wallet":"5a7d9f52ba1923b107b80baabe0c3574","coinSpecific":{"redeemScript":"0020e26a7cace11e649369e123bd1b41705e11112b50614af287db7c2e4bed4fc0c8","witnessScript":"5221035326e902af387358efa08235768b3a70a7a630f68ae031a2a043c9b5a20bcacd21020a33b1dfe30a73109bd7f9f7e9fd7b906b1ce3f28d682b87aa7f435a34ff8d5721030b610df9f6e209f7cec3da6c718861a7501f8eff46851235de7d4f7eebbbc19e53ae"}}' }
      it { is_expected.to eq(address: nil, bitgo_address_id: '5acb44423a713ade07b42b0140f91a96') }
    end

    context 'when BitGo address ID is provided' do
      let(:request_path) { '/tbtc/wallet/' + currency.bitgo_wallet_id + '/address/5acb44423a713ade07b42b0140f91a96' }
      let(:request_method) { :get }
      before { options.merge!(address_id: '5acb44423a713ade07b42b0140f91a96') }
      it 'tries to fetch address from BitGo using different request' do
        expect(subject).to eq(address: '2MySruptM4SgZF49KSc3x5KyxAW61ghyvtc')
      end
      context 'when address still is not initialized by BitGo' do
        let(:response_body) { '{"id":"5acb44423a713ade07b42b0140f91a96","chain":10,"index":25278,"coin":"tbtc","wallet":"5a7d9f52ba1923b107b80baabe0c3574","coinSpecific":{"redeemScript":"0020e26a7cace11e649369e123bd1b41705e11112b50614af287db7c2e4bed4fc0c8","witnessScript":"5221035326e902af387358efa08235768b3a70a7a630f68ae031a2a043c9b5a20bcacd21020a33b1dfe30a73109bd7f9f7e9fd7b906b1ce3f28d682b87aa7f435a34ff8d5721030b610df9f6e209f7cec3da6c718861a7501f8eff46851235de7d4f7eebbbc19e53ae"}}' }
        it { is_expected.to eq({}) }
      end
    end
  end
end
