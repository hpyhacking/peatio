# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class Support
    include CanCan::Ability

    def initialize(user)
      can :read, Member
      can :read, Deposit
      can :read, Withdraw
      can :read, Account
    end
  end
end
