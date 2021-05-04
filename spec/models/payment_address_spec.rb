# encoding: UTF-8
# frozen_string_literal: true

describe PaymentAddress do
  context '.create' do
    let(:member)  { create(:member, :level_3) }
    let!(:account) { member.get_account(:btc) }
    let!(:wallet) { Wallet.joins(:currencies).find_by(currencies: { id: :btc }) }
    let(:secret) { 's3cr3t' }
    let(:details) { { 'a' => 'b', 'b' => 'c' } }
    let!(:addr) { create(:payment_address, :btc_address, address: nil, secret: secret, wallet_id: wallet.id) }

    it 'generate address after commit' do
      AMQP::Queue.expects(:enqueue).with(:deposit_coin_address, { member_id: member.id, wallet_id: wallet.id }, { persistent: true })
      member.payment_address(wallet.id)
    end

    it 'blockchain_key same as wallet blockchain_key' do
      expect(addr.blockchain_key).to eq wallet.blockchain_key
    end

    it 'updates secret' do
      expect {
        addr.update(secret: 'new_secret')
      }.to change { addr.reload.secret_encrypted }.and change { addr.reload.secret }.to 'new_secret'
    end

    it 'updates details' do
      expect {
        addr.update(details: details)
      }.to change { addr.reload.details_encrypted }.and change { addr.reload.details }.to details
    end

    it 'long secret' do
      expect {
        addr.update(secret: Faker::String.random(1024))
      }.to raise_error ActiveRecord::ValueTooLong
    end

    it 'long details' do
      expect {
        addr.update(details: { test: Faker::String.random(1024) })
      }.to raise_error ActiveRecord::ValueTooLong
    end
  end

  context 'methods' do
    context 'status' do
      let(:member)  { create(:member, :level_3) }
      let!(:account) { member.get_account(:btc) }
      let!(:wallet) { Wallet.joins(:currencies).find_by(currencies: { id: :btc }) }

      context 'pending' do
        let!(:addr) { create(:payment_address, :btc_address, address: nil, wallet_id: wallet.id) }

        it { expect(addr.status).to eq 'pending' }
      end

      context 'active' do
        let!(:addr) { create(:payment_address, :btc_address, wallet_id: wallet.id) }

        it { expect(addr.status).to eq 'active' }
      end

      context 'disabled' do
        before do
          wallet.update(status: 'disabled')
        end

        let!(:addr) { create(:payment_address, :btc_address, wallet_id: wallet.id) }

        it { expect(addr.status).to eq 'disabled' }
      end

      context 'retired' do
        before do
          wallet.update(status: 'retired')
        end

        let!(:addr) { create(:payment_address, :btc_address, wallet_id: wallet.id) }

        it { expect(addr.status).to eq 'retired' }
      end
    end
  end
end
