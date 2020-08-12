# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Entities::Deposit do
  context 'fiat' do
    let(:record) { create(:deposit_usd, member: create(:member, :barong)) }

    subject { OpenStruct.new API::V2::Management::Entities::Deposit.represent(record).serializable_hash }

    it do
      expect(subject.tid).to eq record.tid
      expect(subject.currency).to eq 'usd'
      expect(subject.uid).to eq record.member.uid
      expect(subject.type).to eq 'fiat'
      expect(subject.amount).to eq record.amount.to_s
      expect(subject.state).to eq record.aasm_state
      expect(subject.created_at).to eq record.created_at.iso8601
      expect(subject.completed_at).to eq record.completed_at&.iso8601
      expect(subject.respond_to?(:blockchain_txid)).to be_falsey
      expect(subject.respond_to?(:confirmations)).to be_falsey
    end
  end

  context 'coin' do
    let(:record) { create(:deposit_btc, member: create(:member, :barong)) }

    subject { OpenStruct.new API::V2::Management::Entities::Deposit.represent(record).serializable_hash }

    it do
      expect(subject.tid).to eq record.tid
      expect(subject.currency).to eq 'btc'
      expect(subject.uid).to eq record.member.uid
      expect(subject.type).to eq 'coin'
      expect(subject.amount).to eq record.amount.to_s
      expect(subject.state).to eq record.aasm_state
      expect(subject.created_at).to eq record.created_at.iso8601
      expect(subject.completed_at).to eq record.completed_at&.iso8601
      expect(subject.blockchain_txid).to eq record.txid
      expect(subject.blockchain_confirmations).to eq record.confirmations
    end
  end
end
