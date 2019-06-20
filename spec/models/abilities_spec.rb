# encoding: UTF-8
# frozen_string_literal: true

describe Abilities do

  context 'abilities for superadmin' do
    let(:member) { create(:member, role: 'superadmin') }
    subject(:ability) { Abilities.new(member) }

    it { is_expected.to be_able_to(:manage, Account.new) }
    it { is_expected.to be_able_to(:manage, Currency.new) }
    it { is_expected.to be_able_to(:manage, Deposit.new) }
    it { is_expected.to be_able_to(:manage, Withdraw.new) }
    it { is_expected.to be_able_to(:manage, Operations::Account.new) }
    it { is_expected.to be_able_to(:manage, Operations::Asset.new) }
    it { is_expected.to be_able_to(:manage, Operations::Expense.new) }
    it { is_expected.to be_able_to(:manage, Operations::Liability.new) }
    it { is_expected.to be_able_to(:manage, Operations::Revenue.new) }
    it { is_expected.to be_able_to(:manage, Market.new) }
    it { is_expected.to be_able_to(:manage, Blockchain.new) }
    it { is_expected.to be_able_to(:manage, Wallet.new) }
    it { is_expected.to be_able_to(:manage, PaymentAddress.new) }
    it { is_expected.to be_able_to(:manage, Member.new) }
    it { is_expected.to be_able_to(:read, Order.new) }
    it { is_expected.to be_able_to(:read, Trade.new) }
    it { is_expected.not_to be_able_to(:write, Trade.new) }
    it { is_expected.not_to be_able_to(:write, Order.new) }
  end

  context 'abilities for admin' do
    let(:member) { create(:member, role: 'admin') }
    subject(:ability) { Abilities.new(member) }

    it { is_expected.to be_able_to(:manage, Currency.new) }
    it { is_expected.to be_able_to(:manage, Deposit.new) }
    it { is_expected.to be_able_to(:manage, Withdraw.new) }
    it { is_expected.to be_able_to(:manage, Operations::Account.new) }
    it { is_expected.to be_able_to(:manage, Operations::Asset.new) }
    it { is_expected.to be_able_to(:manage, Operations::Expense.new) }
    it { is_expected.to be_able_to(:manage, Operations::Liability.new) }
    it { is_expected.to be_able_to(:manage, Operations::Revenue.new) }
    it { is_expected.to be_able_to(:manage, Market.new) }
    it { is_expected.to be_able_to(:manage, Blockchain.new) }
    it { is_expected.to be_able_to(:manage, Wallet.new) }
    it { is_expected.to be_able_to(:read, PaymentAddress.new) }
    it { is_expected.to be_able_to(:read, Member.new) }
    it { is_expected.to be_able_to(:read, Order.new) }
    it { is_expected.to be_able_to(:read, Trade.new) }
    it { is_expected.to be_able_to(:read, Account.new) }
    it { is_expected.not_to be_able_to(:write, PaymentAddress.new) }
    it { is_expected.not_to be_able_to(:write, Member.new) }
    it { is_expected.not_to be_able_to(:write, Order.new) }
    it { is_expected.not_to be_able_to(:write, Trade.new) }
    it { is_expected.not_to be_able_to(:write, Account.new) }
  end

  context 'abilities for compliance' do
    let(:member) { create(:member, role: 'compliance') }
    subject(:ability) { Abilities.new(member) }

    it { is_expected.to be_able_to(:read, Account.new) }
    it { is_expected.to be_able_to(:read, Deposit.new) }
    it { is_expected.to be_able_to(:read, Withdraw.new) }
    it { is_expected.to be_able_to(:read, PaymentAddress.new) }
    it { is_expected.to be_able_to(:read, Operations::Account.new) }
    it { is_expected.to be_able_to(:read, Operations::Asset.new) }
    it { is_expected.to be_able_to(:read, Operations::Expense.new) }
    it { is_expected.to be_able_to(:read, Operations::Liability.new) }
    it { is_expected.to be_able_to(:read, Operations::Revenue.new) }
    it { is_expected.to be_able_to(:read, Member.new) }
    it { is_expected.not_to be_able_to(:write, Member.new) }
    it { is_expected.not_to be_able_to(:write, Account.new) }
    it { is_expected.not_to be_able_to(:write, Account.new) }
    it { is_expected.not_to be_able_to(:write, Deposit.new) }
    it { is_expected.not_to be_able_to(:write, Withdraw.new) }
    it { is_expected.not_to be_able_to(:write, PaymentAddress.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Account.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Asset.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Expense.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Liability.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Revenue.new) }
  end

  context 'abilities for support' do
    let(:member) { create(:member, role: 'support') }
    subject(:ability) { Abilities.new(member) }

    it { is_expected.to be_able_to(:read, Account.new) }
    it { is_expected.to be_able_to(:read, Deposit.new) }
    it { is_expected.to be_able_to(:read, Withdraw.new) }
    it { is_expected.to be_able_to(:read, Member.new) }
    it { is_expected.not_to be_able_to(:write, Member.new) }
    it { is_expected.not_to be_able_to(:write, Account.new) }
    it { is_expected.not_to be_able_to(:write, Deposit.new) }
    it { is_expected.not_to be_able_to(:write, Withdraw.new) }
    it { is_expected.not_to be_able_to(:write, PaymentAddress.new) }
  end

  context 'abilities for technical' do
    let(:member) { create(:member, role: 'technical') }
    subject(:ability) { Abilities.new(member) }

    it { is_expected.to be_able_to(:manage, Market.new) }
    it { is_expected.to be_able_to(:manage, Currency.new) }
    it { is_expected.to be_able_to(:manage, Blockchain.new) }
    it { is_expected.to be_able_to(:manage, Wallet.new) }
    it { is_expected.to be_able_to(:read, Member.new) }
    it { is_expected.to be_able_to(:read, Deposit.new) }
    it { is_expected.to be_able_to(:read, Withdraw.new) }
    it { is_expected.to be_able_to(:read, Account.new) }
    it { is_expected.to be_able_to(:read, PaymentAddress.new) }
    it { is_expected.not_to be_able_to(:write, Member.new) }
    it { is_expected.not_to be_able_to(:write, Deposit.new) }
    it { is_expected.not_to be_able_to(:write, Withdraw.new) }
    it { is_expected.not_to be_able_to(:write, Account.new) }
    it { is_expected.not_to be_able_to(:write, PaymentAddress.new) }
  end

  context 'abilities for accountant' do
    let(:member) { create(:member, role: 'accountant') }
    subject(:ability) { Abilities.new(member) }

    it { is_expected.to be_able_to(:read, Deposit.new) }
    it { is_expected.to be_able_to(:read, Withdraw.new) }
    it { is_expected.to be_able_to(:read, Account.new) }
    it { is_expected.to be_able_to(:read, PaymentAddress.new) }
    it { is_expected.to be_able_to(:read, Operations::Account.new) }
    it { is_expected.to be_able_to(:read, Operations::Asset.new) }
    it { is_expected.to be_able_to(:read, Operations::Expense.new) }
    it { is_expected.to be_able_to(:read, Operations::Liability.new) }
    it { is_expected.to be_able_to(:read, Operations::Revenue.new) }
    it { is_expected.to be_able_to(:read, Member.new) }
    it { is_expected.not_to be_able_to(:write, Member.new) }
    it { is_expected.not_to be_able_to(:write, Deposit.new) }
    it { is_expected.not_to be_able_to(:write, Withdraw.new) }
    it { is_expected.not_to be_able_to(:write, Account.new) }
    it { is_expected.not_to be_able_to(:write, PaymentAddress.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Account.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Asset.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Expense.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Liability.new) }
    it { is_expected.not_to be_able_to(:write, Operations::Revenue.new) }
  end
end
