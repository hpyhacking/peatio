class AdminAbility
  include CanCan::Ability

  def initialize(member)
    return if Ability.admin_permissions[member.role].nil?

    # Iterate through member permissions
    Ability.admin_permissions[member.role].each do |action, rules|
      # Iterate through a list of member model access
      rules.each do |rule|
        # check if rule define attributes
        if rule.is_a?(Hash)
          model = rule.keys.first
          attributes = rule[model].map(&:to_sym)
          # example, can :update, Currency, [:visible, :name] (model attributes)
        else
          model = rule
          # example, can :update, Currency
        end
        can action.to_sym, model == 'all' ? model.to_sym : model.constantize, attributes
      end
    end
  end
end
