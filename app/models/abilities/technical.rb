# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class Technical
    include CanCan::Ability

    def initialize(user)
      can :read, Member
      can :read, Deposit
      can :read, Withdraw
      can :read, Account
      can :read, PaymentAddress

      can :manage, Market
      can :manage, Currency
      can :manage, Blockchain
      can :manage, Wallet
    end
  end
end
