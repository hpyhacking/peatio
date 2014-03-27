class WithdrawChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  set_filename "withdraw_channel"

  def self.get(key)
    WithdrawChannel.where(key: key).first
  end
end
