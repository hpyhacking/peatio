# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Entities::Member do
  let(:member) { create(:member, :level_3) }

  subject { OpenStruct.new APIv2::Entities::Member.represent(member).serializable_hash }

  it { expect(subject.sn).to eq member.sn }
  it { expect(subject.email).to eq member.email }

  it 'accounts' do
    expect(subject.accounts).to match [
      { currency: 'bch', balance: '0.0', locked: '0.0' },
      { currency: 'btc', balance: '0.0', locked: '0.0' },
      { currency: 'dash', balance: '0.0', locked: '0.0' },
      { currency: 'eth', balance: '0.0', locked: '0.0' },
      { currency: 'ltc', balance: '0.0', locked: '0.0'},
      { currency: 'trst', balance: '0.0', locked: '0.0' },
      { currency: 'usd', balance: '0.0', locked: '0.0' },
      { currency: 'xrp', balance: '0.0', locked: '0.0' }
    ]
  end
end
