# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class Accountant
    include CanCan::Ability

    def initialize
      can :read, Operations::Account
      can :read, Operations::Asset
      can :read, Operations::Expense
      can :read, Operations::Liability
      can :read, Operations::Revenue

      can :read, Member
      can :read, Deposit
      can :read, Withdraw
      can :read, Account
      can :read, PaymentAddress

      can :create, Deposits::Fiat
      can :create, Adjustment
    end
  end
end
