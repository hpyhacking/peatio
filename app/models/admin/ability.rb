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
      Deposit.descendants.each { |d| can :manage, d }

      can :menu, Withdraw
      Withdraw.descendants.each { |w| can :manage, w }
    end
  end
end
