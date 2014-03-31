class DepositChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  include ChannelInternational

  include ActiveHash::Associations
  belongs_to :currency_obj, class_name: 'Currency', foreign_key: 'currency', primary_key: 'code'
end
