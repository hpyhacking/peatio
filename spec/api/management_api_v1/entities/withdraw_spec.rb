# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Withdraw do
  context 'fiat' do
    let(:rid) { Faker::Bank.iban }
    let(:member) { create(:member, :barong) }
    let(:record) { create(:usd_withdraw, member: member, rid: rid) }

    subject { OpenStruct.new ManagementAPIv1::Entities::Withdraw.represent(record).serializable_hash }

    it { expect(subject.tid).to eq record.tid }
    it { expect(subject.rid).to eq rid }
    it { expect(subject.currency).to eq 'usd' }
    it { expect(subject.uid).to eq record.member.uid }
    it { expect(subject.type).to eq 'fiat' }
    it { expect(subject.amount).to eq record.amount.to_s }
    it { expect(subject.fee).to eq record.fee.to_s }
    it { expect(subject.respond_to?(:txid)).to be_falsey }
    it { expect(subject.state).to eq record.aasm_state }
    it { expect(subject.created_at).to eq record.created_at.iso8601 }
  end

  context 'coin' do
    let(:rid) { Faker::Bitcoin.address }
    let(:member) { create(:member, :barong) }
    let(:record) { create(:btc_withdraw, member: member, rid: rid) }

    subject { OpenStruct.new ManagementAPIv1::Entities::Withdraw.represent(record).serializable_hash }

    it { expect(subject.tid).to eq record.tid }
    it { expect(subject.rid).to eq rid }
    it { expect(subject.currency).to eq 'btc' }
    it { expect(subject.uid).to eq record.member.uid }
    it { expect(subject.type).to eq 'coin' }
    it { expect(subject.amount).to eq record.amount.to_s }
    it { expect(subject.fee).to eq record.fee.to_s }
    it { expect(subject.blockchain_txid).to eq record.txid }
    it { expect(subject.state).to eq record.aasm_state }
    it { expect(subject.created_at).to eq record.created_at.iso8601 }
  end
end
