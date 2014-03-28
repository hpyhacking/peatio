class DepositChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  include ChannelInternational
end
