describe Currency do
  let!(:deposit_fee) { currency.deposit_fee }
  after { currency.update_columns(deposit_fee: deposit_fee) }

  context 'fiat' do
    let(:currency) { Currency.find_by_code!(:usd) }
    it 'allows to change deposit fee' do
      currency.update!(deposit_fee: 0.25)
      expect(currency.deposit_fee).to eq 0.25
    end
  end

  context 'coin' do
    let(:currency) { Currency.find_by_code!(:btc) }
    it 'doesn\'t allow to change deposit fee' do
      currency.update!(deposit_fee: 0.25)
      expect(currency.deposit_fee).to eq 0
    end
  end
end
