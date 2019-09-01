# encoding: UTF-8
# frozen_string_literal: true

describe Adjustment do
  let!(:member) { create(:member) }
  subject { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}") }

  context 'on create' do
    it 'does not insert liability' do
      expect {
        subject
      }.not_to change { Operations::Liability.count }
    end

    it 'does not insert asset' do
      expect {
        subject
      }.not_to change { Operations::Asset.count }
    end

    it 'builds operations' do
      operations = subject.fetch_operations

      expect(operations).not_to be_empty
      expect(operations.length).to eq 2
      expect(operations.map(&:valid?)).to be_truthy
      expect(operations.map(&:reference_type)).to all eq 'Adjustment'
    end
  end

  context '#prebuild_operations' do
    subject { adjustment.prebuild_operations }

    context 'asset and liability' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}", amount: 1) }

      it { expect(subject.first.is_a?(Operations::Asset)).to be_truthy }
      it { expect(subject.second.is_a?(Operations::Liability)).to be_truthy }
      it { expect(subject.first.credit).to eq(1) }
      it { expect(subject.second.credit).to eq(1) }

      context 'negative amount' do
        let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-202-#{member.uid}", amount: -1) }

        it { expect(subject.first.debit).to eq(1) }
        it { expect(subject.second.debit).to eq(1) }
      end
    end

    context 'asset and revenue' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-302", amount: 1) }

      it { expect(subject.first.is_a?(Operations::Asset)).to be_truthy }
      it { expect(subject.second.is_a?(Operations::Revenue)).to be_truthy }
      it { expect(subject.first.credit).to eq(1) }
      it { expect(subject.second.credit).to eq(1) }

      context 'negative amount' do
        let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-302", amount: -1) }

        it { expect(subject.first.debit).to eq(1) }
        it { expect(subject.second.debit).to eq(1) }
      end
    end

    context 'asset and expense' do
      let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-402", amount: 1) }

      it { expect(subject.first.is_a?(Operations::Asset)).to be_truthy }
      it { expect(subject.second.is_a?(Operations::Expense)).to be_truthy }
      it { expect(subject.first.credit).to eq(1) }
      it { expect(subject.second.debit).to eq(1) }

      context 'negative amount' do
        let!(:adjustment) { create(:adjustment, currency_id: 'btc', receiving_account_number: "btc-402", amount: -1) }

        it { expect(subject.first.debit).to eq(1) }
        it { expect(subject.second.credit).to eq(1) }
      end
    end
  end

  context 'on accept' do
    it { expect { subject.accept!(validator: member) }.to change { Operations::Asset.count }.by(1) }
    it { expect { subject.accept!(validator: member) }.to change { Operations::Liability.count }.by(1) }
    it { expect { subject.accept!(validator: member) }.to change { subject.state }.to('accepted') }

    it 'operaions have correct reference' do
      subject.accept!(validator: member)
      operations = subject.fetch_operations
      expect(operations.map(&:reference_type)).to all eq 'Adjustment'
      expect(operations.map(&:reference_id)).to all eq subject.id
    end

    it 'updates legacy balances' do
      expect {
        subject.accept!(validator: member)
      }.to change { member.accounts.find_by(currency: subject.currency).balance }.by(subject.amount)
    end

    it 'does not accept with invalid attributes' do
      subject.update(asset_account_code: 101)

      expect {
        subject.accept!(validator: member)
      }.to_not change { subject.state }
    end

    it 'does not accept without validator' do
      subject.update(asset_account_code: 101)

      expect {
        subject.accept!(validator: nil)
      }.to_not change { subject.state }
    end

    it 'does not create operations with invalid attributes' do
      subject.update(asset_account_code: 101)
      expect {
        subject.accept!(validator: member)
      }.not_to change { Operations::Asset.count }

      expect {
        subject.accept!(validator: member)
      }.not_to change { Operations::Liability.count }
    end

    context 'accepted' do
      before { subject.accept!(validator: member) }

      it { expect { subject.accept!(validator: member) }.not_to change { subject.state } }
      it { expect { subject.accept!(validator: member) }.not_to change { member.accounts } }
      it { expect { subject.reject!(validator: member) }.not_to change { subject.state } }
    end

    context 'accept without validator_id (presence validation)' do
      before { subject.update(state: 'accepted') }

      it { expect(*subject.errors.full_messages).to eq('Validator can\'t be blank') }
    end

    context 'accept with validator_id (presence validation)' do
      before { subject.update(state: 'accepted', validator: member) }

      it { expect(subject.save).to be_truthy }
    end
  end

  context 'on reject' do
    it { expect { subject.reject!(validator: member) }.to change { subject.state }.to('rejected') }

    it 'does not reject without validator' do
      subject.update(asset_account_code: 101)

      expect {
        subject.reject!(validator: nil)
      }.to_not change { subject.state }
    end

    context 'rejected' do
      before do
        subject.reject!(validator: member)
      end

      it { expect { subject.accept!(validator: member) }.not_to change { subject.state } }
      it { expect { subject.accept!(validator: member) }.not_to change { member.accounts } }
      it { expect { subject.reject!(validator: member) }.not_to change { subject.state } }
    end
  end
end
