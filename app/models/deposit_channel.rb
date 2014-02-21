class DepositChannel < ActiveYaml::Base
  include Enumerizeable

  set_root_path "#{Rails.root}/config"
  set_filename "deposit_channel"

  def self.currency(category)
    self.find_by_id(category).currency.to_s
  end

  def transfer_text
    I18n.t("peatio.deposit_channel.#{id}.transfer")
  end

  def latency_text
    I18n.t("peatio.deposit_channel.#{id}.latency") 
  end

  def name_text
    I18n.t("peatio.deposit_channel.#{id}.name")
  end

  def intro_text
    I18n.t("peatio.deposit_channel.#{id}.intro")
  end
end
