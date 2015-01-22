class DepositChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International

  def accounts
    bank_accounts.map {|i| OpenStruct.new(i) }
  end

  def as_json(options = {})
    super(options)['attributes'].merge({resource_name: key.pluralize})
  end
end
