class Market < ActiveYaml::Base
  include Enumerizeable

  set_root_path "#{Rails.root}/config"
  set_filename "market"

  def to_s
    id
  end
end

