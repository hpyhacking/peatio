class WithdrawChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International

  def as_json(options = {})
    self.attributes[:resource_name] = key.pluralize
    super(options)
  end
end
