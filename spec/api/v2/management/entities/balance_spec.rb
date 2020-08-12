# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Entities::Balance do
  let(:member) { create(:member, :barong) }
  let(:record) { member.get_account(:usd) }
  before { record.update!(balance: 1000.85, locked: 330.55) }
  subject { OpenStruct.new API::V2::Management::Entities::Balance.represent(record).serializable_hash }

  it do
    expect(subject.uid).to eq record.member.uid
    expect(subject.balance).to eq '1000.85'
    expect(subject.locked).to eq '330.55'
  end
end
