class Bank < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  set_filename "banks"
end
