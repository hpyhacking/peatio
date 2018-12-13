# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Entities::Operation do
  Operation::PLATFORM_TYPES.each do |op_type|
    context op_type do
      let(:record) { create(op_type) }

      subject { OpenStruct.new API::V2::Management::Entities::Operation.represent(record).serializable_hash }

      it { expect(subject.code).to eq record.code }
      it { expect(subject.currency).to eq record.currency_id }
      it { expect(subject.created_at).to eq record.created_at.iso8601 }
      it { expect(subject.respond_to?(:uid)).to be_falsey }

      context 'credit' do
        it { expect(subject.credit).to eq record.credit }
        it { expect(subject.respond_to?(:debit)).to be_falsey }
      end

      context 'credit' do
        let(:record) { create(:asset, :debit) }
        it { expect(subject.debit).to eq record.debit }
        it { expect(subject.respond_to?(:credit)).to be_falsey }
      end
    end
  end

  Operation::MEMBER_TYPES.each do |op_type|
    context op_type do
      let(:record) { create(op_type) }

      subject { OpenStruct.new API::V2::Management::Entities::Operation.represent(record).serializable_hash }

      it { expect(subject.code).to eq record.code }
      it { expect(subject.currency).to eq record.currency_id }
      it { expect(subject.uid).to eq record.member.uid }
      it { expect(subject.created_at).to eq record.created_at.iso8601 }

      context 'credit' do
        it { expect(subject.credit).to eq record.credit }
        it { expect(subject.respond_to?(:debit)).to be_falsey }
      end

      context 'credit' do
        let(:record) { create(:asset, :debit) }
        it { expect(subject.debit).to eq record.debit }
        it { expect(subject.respond_to?(:credit)).to be_falsey }
      end
    end
  end
end
