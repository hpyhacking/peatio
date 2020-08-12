# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Entities::Account do
  let(:account) { create_account(:btc, balance: 100) }

  subject { OpenStruct.new API::V2::Entities::Account.represent(account).serializable_hash }

  it do
    expect(subject.currency).to eq 'btc'
    expect(subject.balance).to eq '100.0'
    expect(subject.locked).to eq '0.0'
  end
end
