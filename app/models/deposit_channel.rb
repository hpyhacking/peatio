class DepositChannel < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"

  include Channelable
  include HashCurrencible
  include International

  def accounts
    bank_accounts.map {|i| OpenStruct.new(i) }
  end
end
