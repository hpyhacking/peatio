class DepositChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International

  def as_json(*)
    super.fetch('attributes')
  end
end
