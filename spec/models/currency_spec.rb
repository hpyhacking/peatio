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

  context 'scopes' do
    let(:currency) { Currency.find(:btc) }

    context 'visible' do
      it 'changes visible scope count' do
        visible = Currency.visible.count
        currency.update(status: :disabled)
        expect(Currency.visible.count).to eq(visible - 1)
      end
    end

    context 'coins_without_tokens' do
      it 'expose coins with blockchain_currencies parent_id nil' do
        result = Currency.coins_without_tokens
        expect(result.count).to eq 2
        expect(result.ids).to eq %w[btc eth]
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

  context 'Callbacks' do
    context 'after_create' do
      let!(:coin) { Currency.find(:btc) }

      it 'move to the bottom if there is no position' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test')
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['ring', 6], ['test', 7]]
      end

      it 'move to the bottom of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', position: 7)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['ring', 6], ['test', 7]]
      end

      it 'move to the bottom when position is greater that currencies count' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', position: Currency.all.count + 2)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['ring', 6], ['test', 7]]
      end

      it 'move to the top of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', position: 1)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['test', 1], ['usd', 2], ['eur', 3], ['btc', 4],
                                                                  ['eth', 5], ['trst', 6], ['ring', 7]]
      end

      it 'move to the middle of all currencies' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', position: 5)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['test', 5], ['trst', 6], ['ring', 7]]
      end

      it 'position equal to currencies amount' do
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3],
                                                                  ['eth', 4], ['trst', 5], ['ring', 6]]
        Currency.create(code: 'test', position: 6)
        expect(Currency.all.ordered.pluck(:id, :position)).to eq [['usd', 1], ['eur', 2], ['btc', 3], ['eth', 4],
                                                                  ['trst', 5], ['test', 6], ['ring', 7]]
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

  context 'Methods' do
    context 'update price' do
      let(:currency) { Currency.find(:eth) }

      context 'there is no market' do
        it do
          prev_currency_price = currency.price
          currency.update_price
          expect(currency.price).to eq prev_currency_price
        end
      end

      context 'market exists' do
        let!(:platform_currency) { create(:currency, :eth, id: 'usdt')}
        let!(:market) { create(:market, symbol: 'ethusdt', type: 'spot', base_currency: 'eth', quote_currency: platform_currency.id,
                               amount_precision: 4, price_precision: 6, min_price: 0.000001, min_amount: 0.0001)}

        context 'there is no ticker' do
          before do
            delete_measurments('trades')
          end

          it do
            prev_currency_price = currency.price
            currency.update_price
            expect(currency.price).to eq prev_currency_price
          end
        end

        context 'there is ticker' do
          let!(:trade) { create(:trade, :btcusd, market_id: market.symbol, market_type: 'spot', price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}

          before do
            trade.write_to_influx
          end

          it do
            prev_currency_price = currency.price
            currency.update_price
            expect(currency.price_previous_change).to eq [prev_currency_price, trade.price]
          end
        end
      end
    end
  end
end
