# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class Superadmin
    include CanCan::Ability

    def initialize
      can :read, Order
      can :read, Trade

      can :manage, Member
      can :manage, Deposit
      can :manage, Withdraw

      can :manage, Operations::Account
      can :manage, Operations::Asset
      can :manage, Operations::Expense
      can :manage, Operations::Liability
      can :manage, Operations::Revenue

      can :manage, Market
      can :manage, Currency
      can :manage, Blockchain
      can :manage, Account
      can :manage, Wallet
      can :manage, TradingFee
      can :manage, PaymentAddress
      can :manage, Adjustment
    end
  end
end
