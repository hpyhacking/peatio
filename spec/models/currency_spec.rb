# encoding: UTF-8
# frozen_string_literal: true

describe Currency do
  context 'coin' do
    let(:currency) { Currency.find(:btc) }

    it 'validates position' do
      currency.position = 0
      expect(currency.valid?).to be_falsey
      expect(currency.errors[:position].size).to eq(1)
    end

    it 'validate position value on update' do
      currency.update(position: nil)
      expect(currency.valid?).to eq false
      expect(currency.errors[:position].size).to eq(2)

      currency.update(position: 0)
      expect(currency.valid?).to eq false
      expect(currency.errors[:position].size).to eq(1)
    end
  end

  context 'token' do
    let!(:currency) { Currency.find(:ring) }
    let!(:trst_currency) { Currency.find(:trst) }
    let!(:fiat_currency) { Currency.find(:eur) }

    # coin configuration
    it 'validate parent_id presence' do
      currency.parent_id = nil
      expect(currency.valid?).to eq true
    end

    # token configuration
    it 'validate parent_id value' do
      currency.parent_id = fiat_currency.id
      expect(currency.valid?).to be_falsey
      expect(currency.errors[:parent_id]).to eq ["is not included in the list"]

      currency.parent_id = trst_currency.id
      expect(currency.valid?).to be_falsey
      expect(currency.errors[:parent_id]).to eq ["is not included in the list"]
    end
  end

  context 'scopes' do
    let(:currency) { Currency.find(:btc) }

    context 'visible' do
      it 'changes visible scope count' do
        visible = Currency.visible.count
        currency.update(status: :disabled)
        expect(Currency.visible.count).to eq(visible - 1)
      end
    end
  end


  context 'read only attributes' do
    let!(:fake_currency) { create(:currency, :btc, id: 'fake') }

    it 'should not update the type' do
      fake_currency.update_attributes :type => 'fiat'
      expect(fake_currency.reload.type).to eq(fake_currency.type)
    end
  end

  context 'validate max currency' do
    before { ENV['MAX_CURRENCIES'] = '6' }
    after  { ENV['MAX_CURRENCIES'] = nil }

    it 'should raise validation error for max currency' do
      record = build(:currency, :fake, id: 'fake2', type: 'fiat')
      record.save
      expect(record.errors.full_messages).to include(/Max Currency limit has been reached/i)
    end
  end

  context 'Methods' do
    context 'token?' do
      let!(:coin) { Currency.find(:btc) }
      let!(:token) { Currency.find(:trst) }

      it { expect(coin.token?).to eq false }
      it { expect(token.token?).to eq true }
    end
  end

  context 'Callbacks' do
    context 'after_create' do
      let!(:coin) { Currency.find(:btc) }

      it 'move to the bottom if there is no position' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', parent_id: coin.id)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['ring', 6], ['test', 7]]
      end

      it 'move to the bottom of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', parent_id: coin.id, position: 7)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['ring', 6], ['test', 7]]
      end

      it 'move to the bottom when position is greater that currencies count' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', parent_id: coin.id, position: Currency.all.count + 2)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['ring', 6], ['test', 7]]
      end

      it 'move to the top of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', parent_id: coin.id, position: 1)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['test', 1], ['usd', 2], ['eur', 3], ['btc', 4],
                                                                  ['eth', 5], ['trst', 6], ['ring', 7]]
      end

      it 'move to the middle of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', parent_id: coin.id, position: 5)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['test', 5], ['trst', 6], ['ring', 7]]
      end

      it 'position equal to currencies amount' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', parent_id: coin.id, position: 6)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['test', 6], ['ring', 7]]
      end

      context 'link_wallets' do
        let!(:coin) { Currency.find(:eth) }
        let!(:wallet) { Wallet.deposit_wallet(:eth) }

        context 'without parent id' do
          it 'should not create currency wallet' do
            currency = Currency.create(code: 'test')
            expect(CurrencyWallet.find_by(currency_id: currency.id, wallet_id: wallet.id)).to eq nil
          end
        end

        context 'with parent id' do
          it 'should create currency wallet' do
            currency = Currency.create(code: 'test', parent_id: coin.id)
            c_w = CurrencyWallet.find_by(currency_id: currency.id, wallet_id: wallet.id)

            expect(c_w.present?).to eq true
            expect(c_w.currency_id).to eq currency.id
          end
        end
      end
    end

    context 'before update' do
      let!(:coin) { Currency.find(:btc) }

      it 'move to the bottom of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        coin.update(position: 6)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['eth', 3],
                                                                  ['trst', 4], ['ring', 5], ['btc', 6]]
      end

      it 'move to the bottom when position is greater that currencies count' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        coin.update(position: Currency.all.count + 2)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['eth', 3],
                                                                  ['trst', 4], ['ring', 5], ['btc', 6]]
      end

      it 'move to the top of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        coin.update(position: 1)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['btc', 1], ['usd', 2], ['eur', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
      end

      it 'move to the middle of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        coin.update(position: 4)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['eth', 3],
                                                                  ['btc', 4], ['trst', 5], ['ring', 6]]
      end
    end
  end
end
