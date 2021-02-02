# encoding: UTF-8
# frozen_string_literal: true

describe WhitelistedSmartContract, 'Validations' do
  let!(:addresses_1) { create(:whitelisted_smart_contract, :address_1) }
  let!(:addresses_2) { create(:whitelisted_smart_contract, :address_2) }
  let!(:addresses_3) { create(:whitelisted_smart_contract, :address_3) }
  let!(:addresses_4) { create(:whitelisted_smart_contract, :address_4) }

  context 'whitelisted addresses model' do
    subject { build(:whitelisted_smart_contract, :address_5) }

    it 'checks whitelisted address valid record' do
      expect(subject).to be_valid
    end

    it 'validates whitelisted address presence of address' do
      subject.address = nil
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Address can\'t be blank']
    end

    it 'validates whitelisted address presence of blockchain_key' do
      subject.blockchain_key = nil
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ["Blockchain key can't be blank", "Blockchain key is not included in the list"]
    end

    it 'validates whitelisted address inclusion of state' do
      subject.state = 'abc'
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['State is not included in the list']
    end

    it 'validates whitelisted address address uniqueness' do
      subject.address = WhitelistedSmartContract.first.address
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Address has already been taken']
    end
  end
end
