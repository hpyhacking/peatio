module Channelable
  extend ActiveSupport::Concern

  included do
    def self.category
      to_s.underscore.split('_').first.pluralize
    end
  end

  def kls
    "#{self.class.category}/#{key}".camelize.constantize
  end

  def <=>(other)
    self.sort_order <=> other.sort_order
  end
end
