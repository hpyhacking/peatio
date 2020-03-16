# encoding: UTF-8
# frozen_string_literal: true

describe UUID do
  let(:uuid) { UUID.generate }
  let(:invalid_uuid) { "bcfbd6f6-8c-4bcd-b76a-ed68a01347a5" }
  let(:type) { UUID::Type.new }
  let(:correct_uuid) { UUID.validate(uuid) }
  let(:incorrect_uuid) { UUID.validate(invalid_uuid) }

  it 'seizlizes and deserializes correctly' do
    bytes = type.serialize(uuid)

    expect(bytes.bytesize).to eq 16
    expect(type.deserialize(bytes)).to eq uuid
  end

  it 'validates uuid correctly' do
    expect(correct_uuid).to be_truthy
    expect(incorrect_uuid).to be_falsy
  end
end
