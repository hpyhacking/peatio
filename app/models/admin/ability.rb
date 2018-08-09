# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class Ability
    include CanCan::Ability

    def initialize(user)
      return unless user.admin?

      can :read, Order
      can :read, Trade
      can :manage, Member

      can :menu, Deposit
      Deposit.descendants.each { |d| can :manage, d }

      can :menu, Withdraw
      Withdraw.descendants.each { |w| can :manage, w }

      can :manage, Market
      can :manage, Currency
      can :manage, Blockchain
      can :manage, Wallet
    end
  end
end
