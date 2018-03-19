module Channelable
  extend ActiveSupport::Concern

  included do
    def self.category
      name.underscore.split('_').first.pluralize
    end
  end

  def kls
    "#{self.class.category}/#{currency.type}".camelize.constantize
  end
end
