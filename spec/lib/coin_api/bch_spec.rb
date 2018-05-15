# encoding: UTF-8
# frozen_string_literal: true

describe CoinAPI::BCH do
  let(:client) { CoinAPI[:bch] }

  describe '#normalize_address' do
    subject { client.normalize_address(address) }

    context 'legacy address format' do
      let(:address) { '2NFrwq5URJriK9MqamjpBx2xLF8WLTEDD7W' }
      it { is_expected.to eq('2NFrwq5URJriK9MqamjpBx2xLF8WLTEDD7W') }
    end

    context 'cashaddr address format' do
      let(:address) { 'bchtest:qpqtmmfpw79thzq5z7s0spcd87uhn6d34uqqem83hf' }
      it { is_expected.to eq('mmRH4e9WW4ekZUP5HvBScfUyaSUjfQRyvD') }
    end
  end
end
