class Activation < Token
  after_update :activate_identity

  private

  def activate_identity
    identity.update_attributes(is_active: true)
  end
end
