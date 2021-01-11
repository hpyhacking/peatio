# frozen_string_literal: true

describe String do
  it { expect('1.0'.to_d).to eq(BigDecimal('1.0')) }
  it { expect('1.'.to_d).to eq(BigDecimal('1.0')) }
  it { expect('1'.to_d).to eq(BigDecimal('1.0')) }
  it { expect('-1'.to_d).to eq(BigDecimal('-1.0')) }
  it { expect(''.to_d).to eq(BigDecimal('0.0')) }
  it { expect { 'decimal'.to_d }.to raise_error ArgumentError }
end
