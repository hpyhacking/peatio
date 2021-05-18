# encoding: UTF-8
# frozen_string_literal: true

describe AdminAbility do

  context 'abilities for superadmin' do
    let(:member) { create(:member, role: 'superadmin') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:manage, Account.new)
      is_expected.to be_able_to(:manage, Currency.new)
      is_expected.to be_able_to(:manage, Deposit.new)
      is_expected.to be_able_to(:manage, Withdraw.new)
      is_expected.to be_able_to(:manage, Operations::Account.new)
      is_expected.to be_able_to(:manage, Operations::Asset.new)
      is_expected.to be_able_to(:manage, Operations::Expense.new)
      is_expected.to be_able_to(:manage, Operations::Liability.new)
      is_expected.to be_able_to(:manage, Operations::Revenue.new)
      is_expected.to be_able_to(:manage, Market.new)
      is_expected.to be_able_to(:manage, Blockchain.new)
      is_expected.to be_able_to(:manage, Wallet.new)
      is_expected.to be_able_to(:manage, PaymentAddress.new)
      is_expected.to be_able_to(:manage, Member.new)
      is_expected.to be_able_to(:manage, WhitelistedSmartContract.new)

      is_expected.to be_able_to(:read, Account.new)
      is_expected.to be_able_to(:read, Currency.new)
      is_expected.to be_able_to(:read, Deposit.new)
      is_expected.to be_able_to(:read, Withdraw.new)
      is_expected.to be_able_to(:read, Operations::Account.new)
      is_expected.to be_able_to(:read, Operations::Asset.new)
      is_expected.to be_able_to(:read, Operations::Expense.new)
      is_expected.to be_able_to(:read, Operations::Liability.new)
      is_expected.to be_able_to(:read, Operations::Revenue.new)
      is_expected.to be_able_to(:read, Market.new)
      is_expected.to be_able_to(:read, Blockchain.new)
      is_expected.to be_able_to(:read, Wallet.new)
      is_expected.to be_able_to(:read, PaymentAddress.new)
      is_expected.to be_able_to(:read, Member.new)

      is_expected.to be_able_to(:update, Account.new)
      is_expected.to be_able_to(:update, Currency.new)
      is_expected.to be_able_to(:update, Deposit.new)
      is_expected.to be_able_to(:update, Withdraw.new)
      is_expected.to be_able_to(:update, Operations::Account.new)
      is_expected.to be_able_to(:update, Operations::Asset.new)
      is_expected.to be_able_to(:update, Operations::Expense.new)
      is_expected.to be_able_to(:update, Operations::Liability.new)
      is_expected.to be_able_to(:update, Operations::Revenue.new)
      is_expected.to be_able_to(:update, Market.new)
      is_expected.to be_able_to(:update, Blockchain.new)
      is_expected.to be_able_to(:update, Wallet.new)
      is_expected.to be_able_to(:update, PaymentAddress.new)
      is_expected.to be_able_to(:update, Member.new)

      is_expected.to be_able_to(:read, Order.new)
      is_expected.to be_able_to(:update, Order.new)
      is_expected.to be_able_to(:read, Trade.new)
      is_expected.not_to be_able_to(:update, Trade.new)
    end
  end

  context 'abilities for admin' do
    let(:member) { create(:member, role: 'admin') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:manage, Currency.new)
      is_expected.to be_able_to(:manage, Deposit.new)
      is_expected.to be_able_to(:manage, Withdraw.new)
      is_expected.to be_able_to(:manage, Operations::Account.new)
      is_expected.to be_able_to(:manage, Operations::Asset.new)
      is_expected.to be_able_to(:manage, Operations::Expense.new)
      is_expected.to be_able_to(:manage, Operations::Liability.new)
      is_expected.to be_able_to(:manage, Operations::Revenue.new)
      is_expected.to be_able_to(:manage, Account.new)
      is_expected.to be_able_to(:manage, Market.new)
      is_expected.to be_able_to(:manage, Blockchain.new)
      is_expected.to be_able_to(:manage, Wallet.new)
      is_expected.to be_able_to(:manage, PaymentAddress.new)
      is_expected.to be_able_to(:read, PaymentAddress.new)
      is_expected.to be_able_to(:read, Member.new)
      is_expected.to be_able_to(:update, Member.new)
      is_expected.to be_able_to(:read, Order.new)
      is_expected.to be_able_to(:update, Order.new)
      is_expected.to be_able_to(:read, Trade.new)
      is_expected.not_to be_able_to(:update, Trade.new)
    end
  end

  context 'abilities for compliance' do
    let(:member) { create(:member, role: 'compliance') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:read, Account.new)
      is_expected.to be_able_to(:read, Deposit.new)
      is_expected.to be_able_to(:read, Withdraw.new)
      is_expected.to be_able_to(:read, PaymentAddress.new)
      is_expected.to be_able_to(:read, Operations::Account.new)
      is_expected.to be_able_to(:read, Operations::Asset.new)
      is_expected.to be_able_to(:read, Operations::Expense.new)
      is_expected.to be_able_to(:read, Operations::Liability.new)
      is_expected.to be_able_to(:read, Member.new)
    end
  end

  context 'abilities for support' do
    let(:member) { create(:member, role: 'support') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:read, Account.new)
      is_expected.to be_able_to(:read, Deposit.new)
      is_expected.to be_able_to(:read, Withdraw.new)
      is_expected.to be_able_to(:read, Member.new)
      is_expected.not_to be_able_to(:update, Member.new)
      is_expected.not_to be_able_to(:update, Account.new)
      is_expected.not_to be_able_to(:update, Deposit.new)
      is_expected.not_to be_able_to(:update, Withdraw.new)
      is_expected.not_to be_able_to(:update, PaymentAddress.new)
    end
  end

  context 'abilities for technical' do
    let(:member) { create(:member, role: 'technical') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:manage, Market.new)
      is_expected.to be_able_to(:manage, Currency.new)
      is_expected.to be_able_to(:manage, Blockchain.new)
      is_expected.to be_able_to(:manage, Wallet.new)
      is_expected.to be_able_to(:read, Member.new)
      is_expected.to be_able_to(:manage, Engine.new)
      is_expected.to be_able_to(:manage, TradingFee.new)
      is_expected.to be_able_to(:read, Operations::Account.new)
      is_expected.to be_able_to(:read, Operations::Asset.new)
      is_expected.to be_able_to(:read, Operations::Expense.new)
      is_expected.to be_able_to(:read, Operations::Liability.new)
      is_expected.to be_able_to(:read, Order.new)
      is_expected.to be_able_to(:read, Trade.new)
      is_expected.to be_able_to(:read, Member.new)
    end
  end

  context 'abilities for reporter' do
    let(:member) { create(:member, role: 'reporter') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:read, Deposit.new)
      is_expected.to be_able_to(:read, Operations::Account.new)
      is_expected.to be_able_to(:read, Operations::Asset.new)
      is_expected.to be_able_to(:read, Operations::Expense.new)
      is_expected.to be_able_to(:read, Operations::Liability.new)
      is_expected.to be_able_to(:read, Withdraw.new)
      is_expected.to be_able_to(:read, Currency.new)
      is_expected.to be_able_to(:read, Wallet.new)
      is_expected.to be_able_to(:read, Blockchain.new)
    end
  end

  context 'abilities for accountant' do
    let(:member) { create(:member, role: 'accountant') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.to be_able_to(:read, Deposit.new)
      is_expected.to be_able_to(:read, Withdraw.new)
      is_expected.to be_able_to(:read, Account.new)
      is_expected.to be_able_to(:read, PaymentAddress.new)
      is_expected.to be_able_to(:read, Operations::Account.new)
      is_expected.to be_able_to(:read, Operations::Asset.new)
      is_expected.to be_able_to(:read, Operations::Expense.new)
      is_expected.to be_able_to(:read, Operations::Liability.new)
      is_expected.to be_able_to(:read, Operations::Revenue.new)
      is_expected.to be_able_to(:read, Member.new)
      is_expected.to be_able_to(:read, Deposit.new)
      is_expected.to be_able_to(:create, Deposits::Fiat.new)
      is_expected.to be_able_to(:create, Adjustment.new)
    end
  end

  context 'abilities for member' do
    let(:member) { create(:member, role: 'member') }
    subject(:ability) { AdminAbility.new(member) }

    it do
      is_expected.not_to be_able_to(:read, Account.new)
      is_expected.not_to be_able_to(:read, Currency.new)
      is_expected.not_to be_able_to(:read, Deposit.new)
      is_expected.not_to be_able_to(:read, Withdraw.new)
      is_expected.not_to be_able_to(:read, Operations::Account.new)
      is_expected.not_to be_able_to(:read, Operations::Asset.new)
      is_expected.not_to be_able_to(:read, Operations::Expense.new)
      is_expected.not_to be_able_to(:read, Operations::Liability.new)
      is_expected.not_to be_able_to(:read, Operations::Revenue.new)
      is_expected.not_to be_able_to(:read, Market.new)
      is_expected.not_to be_able_to(:read, Blockchain.new)
      is_expected.not_to be_able_to(:read, Wallet.new)
      is_expected.not_to be_able_to(:read, PaymentAddress.new)
      is_expected.not_to be_able_to(:read, Member.new)

      is_expected.not_to be_able_to(:update, Account.new)
      is_expected.not_to be_able_to(:update, Currency.new)
      is_expected.not_to be_able_to(:update, Deposit.new)
      is_expected.not_to be_able_to(:update, Withdraw.new)
      is_expected.not_to be_able_to(:update, Operations::Account.new)
      is_expected.not_to be_able_to(:update, Operations::Asset.new)
      is_expected.not_to be_able_to(:update, Operations::Expense.new)
      is_expected.not_to be_able_to(:update, Operations::Liability.new)
      is_expected.not_to be_able_to(:update, Operations::Revenue.new)
      is_expected.not_to be_able_to(:update, Market.new)
      is_expected.not_to be_able_to(:update, Blockchain.new)
      is_expected.not_to be_able_to(:update, Wallet.new)
      is_expected.not_to be_able_to(:update, PaymentAddress.new)
      is_expected.not_to be_able_to(:update, Member.new)

      is_expected.not_to be_able_to(:destroy, Account.new)
      is_expected.not_to be_able_to(:destroy, Currency.new)
      is_expected.not_to be_able_to(:destroy, Deposit.new)
      is_expected.not_to be_able_to(:destroy, Withdraw.new)
      is_expected.not_to be_able_to(:destroy, Operations::Account.new)
      is_expected.not_to be_able_to(:destroy, Operations::Asset.new)
      is_expected.not_to be_able_to(:destroy, Operations::Expense.new)
      is_expected.not_to be_able_to(:destroy, Operations::Liability.new)
      is_expected.not_to be_able_to(:destroy, Operations::Revenue.new)
      is_expected.not_to be_able_to(:destroy, Market.new)
      is_expected.not_to be_able_to(:destroy, Blockchain.new)
      is_expected.not_to be_able_to(:destroy, Wallet.new)
      is_expected.not_to be_able_to(:destroy, PaymentAddress.new)
      is_expected.not_to be_able_to(:destroy, Member.new)
    end
  end
end
