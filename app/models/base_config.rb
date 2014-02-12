class BaseConfig < Settingslogic
  source "#{Rails.root}/config/base_config.yml"
  namespace Rails.env
  suppress_errors Rails.env.production?
end
