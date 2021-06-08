# encoding: UTF-8
# frozen_string_literal: true

describe Wallet do
  context 'validations' do

    subject { build(:wallet, :eth_cold) }

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

    it 'validates name uniqueness' do
      subject.name = Wallet.first.name
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ['Name has already been taken']
    end

    it 'saves settings in encrypted column' do
      subject.save
      expect {
        subject.uri = 'http://geth:8545/'
        subject.save
      }.to change { subject.settings_encrypted }
    end

    it 'does not update settings_encrypted before model is saved' do
      subject.save
      expect {
        subject.uri = 'http://geth:8545/'
      }.not_to change { subject.settings_encrypted }
    end

    it 'updates setting fields' do
      expect {
        subject.uri = 'http://geth:8545/'
      }.to change { subject.settings['uri'] }.to 'http://geth:8545/'
    end

    it 'long encrypted secret' do
      expect {
        subject.secret = Faker::String.random(1024)
        subject.save!
      }.to raise_error ActiveRecord::ValueTooLong
    end

    context 'gateway_wallet_kind_support' do
      class AbstractWallet < Peatio::Wallet::Abstract
        def initialize(_opts = {}); end
        def configure(settings = {}); end

        def support_wallet_kind?(kind)
          kind == 'hot'
        end
      end

      before(:all) do
        Peatio::Wallet.registry[:abc] = AbstractWallet
      end

      it 'allows to create hot wallet' do
        expect {
          subject.gateway = 'abc'
          subject.kind = 'hot'
          subject.save!
        }.not_to raise_error
      end

      it 'does not allow to create hot wallet' do
        subject.gateway = 'abc'
        subject.kind = 'deposit'
        expect(subject).to_not be_valid
        expect(subject.errors.full_messages).to eq ['Gateway abc can\'t be used as a deposit wallet']
      end
    end
  end
end
