# encoding: UTF-8
# frozen_string_literal: true

describe Matching::PriceLevel do
  subject  { Matching::PriceLevel.new('1.0'.to_d) }
  let(:o1) { Matching.mock_limit_order(type: :ask) }
  let(:o2) { Matching.mock_limit_order(type: :ask) }
  let(:o3) { Matching.mock_limit_order(type: :ask) }

  before do
    subject.add o1
    subject.add o2
    subject.add o3
  end

  it 'should remove order' do
    subject.remove o2
    expect(subject.orders).to eq [o1, o3]
  end

  it 'should find order by id' do
    expect(subject.find(o1.id)).to eq o1
    expect(subject.find(o2.id)).to eq o2
  end
end
