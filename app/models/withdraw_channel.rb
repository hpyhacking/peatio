class WithdrawChannel < ActiveYaml::Base
  extend ActiveModel::Naming
  include ActiveRecord::Inheritance

  set_root_path "#{Rails.root}/config"
  set_filename "withdraw_channel"

  def self.inheritance_column
    'type'
  end

  def self.get
    WithdrawChannel.where(type: self.to_s).first
  end
end
