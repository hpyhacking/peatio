# encoding: UTF-8
# frozen_string_literal: true

describe Wallet do
  context 'validations' do

    subject { build(:wallet, 'eth_warm') }

    it 'checks valid record' do
      expect(subject).to be_valid
    end

    it 'validates presence of address' do
      subject.address = nil
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Address can\'t be blank']
    end

    it 'validates presence of name' do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'validates inclusion of status' do
      subject.status = 'abc'
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Status is not included in the list']
    end

    it 'validates inclusion of kind' do
      subject.kind = 'abc'
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Kind is not included in the list']
    end

    it 'validates nsig should be greater than or equal to 1' do
      subject.nsig = 0
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Nsig must be greater than or equal to 1']
    end

    it 'validates structure of uri' do
      subject.uri = 'Wrong URL'
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Uri is not a valid URL']
    end

    it 'validates name uniqueness' do
      subject.name = Wallet.first.name
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Name has already been taken']
    end
  end
end
