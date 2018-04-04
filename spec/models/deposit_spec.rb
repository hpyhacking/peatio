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

  it 'automatically generates TID if it is blank' do
    expect(create(:deposit_btc).tid).not_to be_blank
  end

  it 'doesn\'t generate TID if it is not blank' do
    expect(create(:deposit_btc, tid: 'TID1234567890').tid).to eq 'TID1234567890'
  end

  it 'validates uniqueness of TID' do
    record1 = create(:deposit_btc)
    record2 = build(:deposit_btc, tid: record1.tid)
    record2.save
    expect(record2.errors.full_messages.first).to match(/tid has already been taken/i)
  end

  it 'uppercases TID' do
    expect(create(:deposit_btc, tid: 'tid').tid).to eq 'TID'
  end
end
