module ChannelInheritable
  extend ActiveSupport::Concern

  included do
    def self.inheritance_column
      'type'
    end

    def self.get
      self.superclass.where(type: self.to_s).first
    end

    def method_missing(name, *args)
      if name =~ /(.*)_text$/
        attr = $1
        I18n.t(i18n_text_key(attr), attr)
      else
        super
      end
    end

    def i18n_text_key(key)
      "deposit_channels.#{self.key}.#{key}"
    end
  end
end
