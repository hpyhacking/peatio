class AdminAbility
  include CanCan::Ability

  def initialize(member)
    return if Ability.admin_permissions[member.role].nil?

    # Iterate through member permissions
    Ability.admin_permissions[member.role].each do |action, models|
      # Iterate through a list of member model access
      models.each do |model|
        can action.to_sym, model == 'all' ? model.to_sym : model.constantize
      end
    end
  end
end
