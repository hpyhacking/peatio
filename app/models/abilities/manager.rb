# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class Manager
    include CanCan::Ability

    def initialize
      can %i[read update], Order
      can :read, Trade
      can :read, Member

      can :read, Deposit
      can :read, Withdraw

      can :read, Operations::Account
      can :read, Operations::Asset
      can :read, Operations::Expense
      can :read, Operations::Liability
      can :read, Operations::Revenue

      can :manage, Currency
      can :manage, Blockchain

      can :read, Account
      can :read, PaymentAddress
    end
  end
end
