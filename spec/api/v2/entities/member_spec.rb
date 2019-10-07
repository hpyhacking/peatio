# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Entities::Member do
  let(:member) { create(:member, :level_3) }

  subject { OpenStruct.new API::V2::Entities::Member.represent(member).serializable_hash }

  it { expect(subject.uid).to eq member.uid }
  it { expect(subject.email).to eq member.email }

  it 'accounts' do
    expect(subject.accounts).to match [
      { currency: 'btc',  balance: '0.0', locked: '0.0' },
      { currency: 'eth',  balance: '0.0', locked: '0.0' },
      { currency: 'eur',  balance: "0.0", locked: '0.0' },
      { currency: 'ring', balance: '0.0', locked: '0.0' },
      { currency: 'trst', balance: '0.0', locked: '0.0' },
      { currency: 'usd',  balance: '0.0', locked: '0.0' },
    ]
  end
end
