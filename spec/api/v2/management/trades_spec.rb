describe API::V2::Management::Trades, type: :request do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  let(:second_member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end


  let(:btcusd_ask) do
    create(
      :order_ask,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_ask) do
    create(
      :order_ask,
      :btceth,
      price: '12.326'.to_d,
      volume: '123.1234',
      member: second_member
    )
  end

  let(:btcusd_bid) do
    create(
      :order_bid,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_bid) do
    create(
      :order_bid,
      :btceth,
      price: '12.326'.to_d,
      volume: '123.1234',
      member: second_member
    )
  end

  let!(:btcusd_ask_trade) { create(:trade, :btcusd, maker_order: btcusd_ask, created_at: 2.days.ago) }
  let!(:btceth_ask_trade) { create(:trade, :btceth, maker_order: btceth_ask, created_at: 2.days.ago) }
  let!(:btcusd_bid_trade) { create(:trade, :btcusd, taker_order: btcusd_bid, created_at: 23.hours.ago) }
  let!(:btceth_bid_trade) { create(:trade, :btceth, taker_order: btceth_bid, created_at: 23.hours.ago) }

  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
    scopes: {
      read_trades:  { permitted_signers: %i[alex jeff],       mandatory_signers: %i[alex] },
    }
  end

  def request
    post_json '/api/v2/management/trades', multisig_jwt_management_api_v1({ data: data }, *signers)
  end

  let(:data) { {} }
  let(:signers) { %i[alex jeff] }

  it 'returns all recent trades' do
    request
    expect(response).to be_successful

    result = JSON.parse(response.body)
    expect(result.count).to eq 4
  end

  it 'returns trades by uid of user' do
    data.merge!(uid: member.uid)
    request
    expect(response).to be_successful

    result = JSON.parse(response.body)
    expect(result.count).to eq 2
  end

  it 'returns trades by market' do
    data.merge!(market: 'btcusd')
    request
    expect(response).to be_successful

    result = JSON.parse(response.body)
    expect(result.count).to eq 2
  end
end
