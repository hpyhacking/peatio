describe PaymentTransaction do
  it 'expect state transfer' do
    tx = create(:payment_transaction, deposit: create(:deposit_btc))
    tx.stubs(:refresh_confirmations)

    tx.stubs(:min_confirm?).returns(false)
    tx.stubs(:max_confirm?).returns(false)

    expect(tx.unconfirm?).to be true
    expect(tx.check).to be false
    expect(tx.check).to be false
    expect(tx.check).to be false
    expect(tx.unconfirm?).to be true

    tx.stubs(:min_confirm?).returns(true)
    tx.stubs(:max_confirm?).returns(false)

    expect(tx.check).to be true
    expect(tx.confirming?).to be true

    tx.stubs(:min_confirm?).returns(false)
    tx.stubs(:max_confirm?).returns(true)

    expect(tx.check).to be true
    expect(tx.confirmed?).to be true
    expect(tx.check).to be true
  end
end
