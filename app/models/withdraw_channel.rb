class WithdrawChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International

  def as_json(options = {})
    super.merge(attributes: {resource_name: key.pluralize})
  end
end
