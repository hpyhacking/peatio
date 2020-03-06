# encoding: UTF-8
# frozen_string_literal: true

describe UUID do
  let(:uuid) { UUID.generate }
  let(:type) { UUID::Type.new }

  it 'seizlizes and deserializes correctly' do
    bytes = type.serialize(uuid)

    expect(bytes.bytesize).to eq 16
    expect(type.deserialize(bytes)).to eq uuid
  end
end
