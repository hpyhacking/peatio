# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Rippled do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'WalletService::Rippled' do

    let(:sign_data) do
      Rails.root.join('spec', 'resources', 'ripple-data', 'sign-transaction.json')
        .yield_self {|file_path| File.open(file_path)}
        .yield_self {|file| JSON.load(file)}
        .to_json
    end

    let(:submit_data) do
      Rails.root.join('spec', 'resources', 'ripple-data', 'submit-transaction.json')
        .yield_self {|file_path| File.open(file_path)}
        .yield_self {|file| JSON.load(file)}
        .to_json
    end

    let(:deposit) {create(:deposit, :deposit_xrp, address: 'rN3J1yMz2PCGievtS2XTEgkrmdHiJgzb5Y', amount: 10)}
    let(:withdraw) {create(:xrp_withdraw)}
    let(:deposit_wallet) { Wallet.find_by(gateway: :rippled, kind: :deposit)}
    let(:hot_wallet) { Wallet.find_by(gateway: :rippled, kind: :hot)}

    context '#create_address!' do
      let(:service) {WalletService[wallet]}
      let(:wallet) {Wallet.find_by(gateway: :rippled, kind: :deposit)}
      let(:create_address) {service.create_address}

      it 'create valid address with destination_tag' do
        address = create_address[:address]
        expect(normalize_address(address)).to eq wallet.address
        expect(destination_tag_from(address).to_i).to be > 0
      end
    end

    context '#collect_deposit' do

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      let!(:payment_address) do
        create(:xrp_payment_address, {account: deposit.account, address: 'rN3J1yMz2PCGievtS2XTEgkrmdHiJgzb5Y?dt=917590223', secret: 'changeme'})
      end

      let :account_info_response do
        { result: '0' }.to_json
      end

      let :account_info_request do
        {
          jsonrpc:  '1.0',
          id:       1,
          method:   'account_info',
          params:
            [
              {
                account:      hot_wallet.address,
                ledger_index: 'validated',
                strict:       true
              }
            ]
        }.to_json
      end

      let :sign_request do
        {jsonrpc: '1.0',
         id:      1,
         method:  'sign',
         params:
           [
             secret: 'changeme',
             tx_json:
               {
                 Account:             deposit.address,
                 Amount:              '9990000',
                 Fee:                 10000,
                 Destination:         hot_wallet.address,
                 DestinationTag:      0,
                 TransactionType:     'Payment',
                 LastLedgerSequence:  31234504
               }
           ]
        }.to_json
      end

      let :submit_request do
        {
          jsonrpc:  '1.0',
          id:       2,
          method:   'submit',
          params:
            [
              tx_blob: '1200002280000000240000016861D4838D7EA4C6800000000000000000000000000055534400000000004B4E9C06F24296074F7BC48F92A97916C6DC5'\
              'EA9684000000000002710732103AB40A0490F9B7ED8DF29D246BF2D6269820A0EE7742ACDD457BEA7C7D0931EDB7446304402200E5C2DD81FDF0BE9AB'\
              '2A8D797885ED49E804DBF28E806604D878756410CA98B102203349581946B0DDA06B36B35DBC20EDA27552C1F167BCF5C6ECFF49C6A46F858081144B4'\
              'E9C06F24296074F7BC48F92A97916C6DC5EA983143E9D4A2B8AA0780F682D136F7A56D6724EF53754'
            ]
        }.to_json
      end

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      before do
        stub_request(:post, hot_wallet.uri).with(body: account_info_request).to_return(body: account_info_response)
        WalletClient[hot_wallet].class.any_instance.expects(:calculate_current_fee).returns(10000)
        WalletClient[hot_wallet].class.any_instance.expects(:latest_block_number).returns(31234500)
        stub_request(:post, deposit_wallet.uri).with(body: sign_request).to_return(body: sign_data)
        stub_request(:post, deposit_wallet.uri).with(body: submit_request).to_return(body: submit_data)
      end

      it do
        is_expected.to eq(["5B31A7518DC304D5327B4887CD1F7DC2C38D5F684170097020C7C9758B973847"])
      end
    end

    context '#build_withdrawal!' do

      let(:withdraw) { create(:xrp_withdraw, rid: 'rf1BiGeXwwQoi8Z2ueFYTEXSwuJYfV2Jpn') }

      let :sign_request do
        { jsonrpc: '1.0',
         id:      1,
         method:  'sign',
         params:
           [
             secret: 'changeme',
             tx_json:
               {
                 Account:             hot_wallet.address,
                 Amount:              '9975000',
                 Fee:                 10000,
                 Destination:         withdraw.rid,
                 DestinationTag:      0,
                 TransactionType:     'Payment',
                 LastLedgerSequence:  31234504
               }
           ]
        }.to_json
      end

      let :submit_request do
        {
          jsonrpc: '1.0',
          id:     2,
          method: 'submit',
          params:
            [
              tx_blob: '1200002280000000240000016861D4838D7EA4C6800000000000000000000000000055534400000000004B4E9C06F24296074F7BC48F92A97916C6DC5'\
              'EA9684000000000002710732103AB40A0490F9B7ED8DF29D246BF2D6269820A0EE7742ACDD457BEA7C7D0931EDB7446304402200E5C2DD81FDF0BE9AB'\
              '2A8D797885ED49E804DBF28E806604D878756410CA98B102203349581946B0DDA06B36B35DBC20EDA27552C1F167BCF5C6ECFF49C6A46F858081144B4'\
              'E9C06F24296074F7BC48F92A97916C6DC5EA983143E9D4A2B8AA0780F682D136F7A56D6724EF53754'
            ]
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw) }

      before do
        WalletClient[hot_wallet].class.any_instance.expects(:calculate_current_fee).returns(10000)
        WalletClient[hot_wallet].class.any_instance.expects(:latest_block_number).returns(31234500)
        # Request with method 'sign' to return a signed binary representation of the transaction.
        stub_request(:post, deposit_wallet.uri).with(body: sign_request).to_return(body: sign_data)
        # Request with method 'submit' method to apply a transaction and send it to the network to be confirmed and included in future ledgers
        stub_request(:post, deposit_wallet.uri).with(body: submit_request).to_return(body: submit_data)
      end

      it do
        is_expected.to eq('5B31A7518DC304D5327B4887CD1F7DC2C38D5F684170097020C7C9758B973847')
      end
    end
  end
end


def normalize_address(address)
  address.gsub(/\?dt=\d*\Z/, '')
end

def destination_tag_from(address)
  address =~ /\?dt=(\d*)\Z/
  $1.to_i
end
