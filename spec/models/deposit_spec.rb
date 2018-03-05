describe Deposit do
  let(:member) { create(:member) }
  let(:deposit) { create(:deposit_btc, member: member, amount: 100.to_d, currency: Currency.find_by!(code: :btc)) }

  it 'should compute fee' do
    expect(deposit.fee).to eql 0.to_d
    expect(deposit.amount).to eql 100.to_d
  end

  context 'when deposit fee 10%' do
    let(:deposit) { create(:deposit_usd, member: member, currency: Currency.find_by!(code: :usd), amount: 100.to_d) }

    before do
      Deposit.any_instance.expects(:calc_fee).once.returns([90, 10])
    end

    it 'should compute fee' do
      expect(deposit.fee).to eql 10.to_d
      expect(deposit.amount).to eql 100.to_d
    end
  end
end
