module Enumerizeable
  extend ActiveSupport::Concern

  included do
    def self.enumerize(key = :id)
      Hash[self.all.map do |x| [x.send(key).to_sym, x.code] end]
    end
  end
end
