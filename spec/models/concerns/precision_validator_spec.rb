# encoding: UTF-8
# frozen_string_literal: true

class Validatable
  include ActiveModel::Validations
  attr_accessor :amount
  validates :amount, precision: { less_than_or_eq_to: 2 }
end

describe PrecisionValidator do
  subject { Validatable.new }

  it 'returns valid record' do
    subject.stubs(amount: 1)
    expect(subject).to be_valid
  end

  it 'returns invalid record with errors' do
    subject.stubs(amount: 0.001)
    expect(subject).not_to be_valid
    expect(subject.errors[:amount]).to include(/precision must be less than or equal to 2/)
  end

  it 'returns invalid record with errors' do
    subject.stubs(amount: '0.001')
    expect(subject).not_to be_valid
    expect(subject.errors[:amount]).to include(/must be a number/)
  end
end
