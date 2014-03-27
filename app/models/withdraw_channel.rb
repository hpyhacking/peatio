class WithdrawChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  set_filename "withdraw_channel"

  extend ActiveModel::Naming
  include ChannelInheritable
  include ActiveRecord::Inheritance

  def self.get
    WithdrawChannel.where(type: self.to_s).first
  end

  def calc_fee(withdraw)
  end
end
