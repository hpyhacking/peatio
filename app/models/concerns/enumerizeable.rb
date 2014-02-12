module Enumerizeable
  extend ActiveSupport::Concern

  included do
    def self.enumerize
      Hash[self.all.map do |x| [x.id.to_sym, x.code] end]
    end
  end
end
