class WithdrawChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"

  include Channelable
  include CurrencibleHash
  include International
end
