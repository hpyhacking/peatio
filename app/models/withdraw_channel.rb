class WithdrawChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International
end
