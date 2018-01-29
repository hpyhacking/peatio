module Admin
  class Ability
    include CanCan::Ability

    def initialize(user)
      return unless user.admin?

      can :read, Order
      can :read, Trade
      can :read, Proof
      can :update, Proof
      can :manage, Member
      can :manage, IdDocument

      can :menu, Deposit
      can :manage, ::Deposits::Bank
      can :manage, ::Deposits::Satoshi
      can :manage, ::Deposits::Ripple
      can :manage, ::Deposits::BitcoinCash
      can :manage, ::Deposits::Litoshi

      can :menu, Withdraw
      can :manage, ::Withdraws::Bank
      can :manage, ::Withdraws::Satoshi
      can :manage, ::Withdraws::Ripple
      can :manage, ::Withdraws::BitcoinCash
      can :manage, ::Withdraws::Litoshi
    end
  end
end
