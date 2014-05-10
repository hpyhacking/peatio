class Bank < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  set_filename "banks"

  def self.fetch
    all.reduce({}){|memo, bank| memo[bank.code] = bank.name; memo}
  end
end
