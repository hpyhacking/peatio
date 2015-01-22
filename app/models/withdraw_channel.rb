class WithdrawChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International

  def blacklist
    self[:blacklist]
  end

  def as_json(options = {})
    super(options)['attributes'].merge({resource_name: key.pluralize})
  end

end
