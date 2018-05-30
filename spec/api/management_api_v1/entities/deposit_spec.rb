# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Deposit do
  context 'fiat' do
    let(:record) { create(:deposit_usd, member: create(:member, :barong)) }

    subject { OpenStruct.new ManagementAPIv1::Entities::Deposit.represent(record).serializable_hash }

    it { expect(subject.tid).to eq record.tid }
    it { expect(subject.currency).to eq 'usd' }
    it { expect(subject.uid).to eq record.member.uid }
    it { expect(subject.type).to eq 'fiat' }
    it { expect(subject.amount).to eq record.amount.to_s }
    it { expect(subject.state).to eq record.aasm_state }
    it { expect(subject.created_at).to eq record.created_at.iso8601 }
    it { expect(subject.completed_at).to eq record.completed_at&.iso8601 }
    it { expect(subject.respond_to?(:blockchain_txid)).to be_falsey }
    it { expect(subject.respond_to?(:confirmations)).to be_falsey }
  end

  context 'coin' do
    let(:record) { create(:deposit_btc, member: create(:member, :barong)) }

    subject { OpenStruct.new ManagementAPIv1::Entities::Deposit.represent(record).serializable_hash }

    it { expect(subject.tid).to eq record.tid }
    it { expect(subject.currency).to eq 'btc' }
    it { expect(subject.uid).to eq record.member.uid }
    it { expect(subject.type).to eq 'coin' }
    it { expect(subject.amount).to eq record.amount.to_s }
    it { expect(subject.state).to eq record.aasm_state }
    it { expect(subject.created_at).to eq record.created_at.iso8601 }
    it { expect(subject.completed_at).to eq record.completed_at&.iso8601 }
    it { expect(subject.blockchain_txid).to eq record.txid }
    it { expect(subject.blockchain_confirmations).to eq record.confirmations }
  end
end
