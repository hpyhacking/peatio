class UUID
  class << self
    def generate
      SecureRandom.uuid
    end
  end

  class Type < ActiveRecord::Type::Value
    def deserialize(value)
      return if value.nil?

      value.unpack('H*').first.tap do |str|
        [20, 16, 12, 8].each { |pos| str.insert(pos, '-') }
      end
    end

    def serialize(value)
      [ value.delete('-') ].pack('H*')
    end
  end
end
