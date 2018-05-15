# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Balance do
  let(:member) { create(:member, :barong) }
  let(:record) { member.ac(:usd) }
  before { record.update!(balance: 1000.85, locked: 330.55) }
  subject { OpenStruct.new ManagementAPIv1::Entities::Balance.represent(record).serializable_hash }

  it { expect(subject.uid).to eq record.member.uid }
  it { expect(subject.balance).to eq '1000.85' }
  it { expect(subject.locked).to eq '330.55' }
end
