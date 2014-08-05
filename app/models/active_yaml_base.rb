class ActiveYamlBase < ActiveYaml::Base
  if Rails.env == 'test'
    set_root_path "#{Rails.root}/spec/fixtures"
  else
    set_root_path "#{Rails.root}/config"
  end
end
