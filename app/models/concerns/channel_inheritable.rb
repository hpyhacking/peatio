module ChannelInheritable
  extend ActiveSupport::Concern

  included do
    def self.inheritance_column
      'type'
    end

    def self.get
      self.superclass.where(type: self.to_s).first
    end
  end
end
