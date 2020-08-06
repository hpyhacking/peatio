class UUID
  class << self
    def generate
      SecureRandom.uuid
    end

    def validate(uuid)
      uuid.match?(/\A[\da-f]{32}\z/i) || uuid.match?(/\A(urn:uuid:)?[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i)
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

    def quoted_id(value)
      return if value.nil?

      "x'#{value.unpack('H*').first}'"
    end
  end
end
