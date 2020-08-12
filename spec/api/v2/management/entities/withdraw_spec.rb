# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Entities::Withdraw do
  context 'fiat' do
    let(:rid) { Faker::Bank.iban }
    let(:member) { create(:member, :barong) }
    let(:record) { create(:usd_withdraw, :with_deposit_liability, member: member, rid: rid) }

    subject { OpenStruct.new API::V2::Management::Entities::Withdraw.represent(record).serializable_hash }

    it do
      expect(subject.tid).to eq record.tid
      expect(subject.rid).to eq rid
      expect(subject.currency).to eq 'usd'
      expect(subject.uid).to eq record.member.uid
      expect(subject.type).to eq 'fiat'
      expect(subject.amount).to eq record.amount.to_s
      expect(subject.note).to eq record.note
      expect(subject.fee).to eq record.fee.to_s
      expect(subject.respond_to?(:txid)).to be_falsey
      expect(subject.state).to eq record.aasm_state
      expect(subject.created_at).to eq record.created_at.iso8601
    end
  end

  context 'coin' do
    let(:rid) { Faker::Blockchain::Bitcoin.address }
    let(:member) { create(:member, :barong) }
    let(:record) { create(:btc_withdraw, :with_deposit_liability, member: member, rid: rid) }

    subject { OpenStruct.new API::V2::Management::Entities::Withdraw.represent(record).serializable_hash }

    it do
      expect(subject.tid).to eq record.tid
      expect(subject.rid).to eq rid
      expect(subject.currency).to eq 'btc'
      expect(subject.uid).to eq record.member.uid
      expect(subject.type).to eq 'coin'
      expect(subject.amount).to eq record.amount.to_s
      expect(subject.note).to eq record.note
      expect(subject.fee).to eq record.fee.to_s
      expect(subject.blockchain_txid).to eq record.txid
      expect(subject.state).to eq record.aasm_state
      expect(subject.created_at).to eq record.created_at.iso8601
    end
  end
end
