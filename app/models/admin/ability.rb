module Admin
  class Ability
    include CanCan::Ability

    def initialize(user)
      return unless user.admin?

      can :read, Order
      can :read, Trade
      can :read, Member
      can :read, Proof
      can :update, Member
      can :toggle, Member
      can :update, Proof
      can :manage, Document
      can :manage, Ticket
      can :manage, IdDocument

      can :menu, Deposit
      can :manage, ::Deposits::Bank
      can :manage, ::Deposits::Satoshi

      can :menu, Withdraw
      can :manage, ::Withdraws::Bank
      can :manage, ::Withdraws::Satoshi

      can :stat, ::Member
    end
  end
end
