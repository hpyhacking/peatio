class WithdrawChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"

  include Channelable
  include HashCurrencible
  include International
end
