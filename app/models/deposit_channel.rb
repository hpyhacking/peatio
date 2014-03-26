class DepositChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  set_filename "deposit_channel"

  extend ActiveModel::Naming
  include ChannelInheritable
  include ActiveRecord::Inheritance
end
