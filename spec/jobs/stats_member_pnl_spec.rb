# frozen_string_literal: true

describe Jobs::Cron::StatsMemberPnl do
  let!(:member_platform) { create(:member, :level_3) }
  let!(:member) { create(:member, :level_3) }
  let!(:maker) { create(:member, role: 'maker') }
  let(:maker2) { create(:member, role: 'maker') }

  include ::API::V2::Management::Helpers

  def create_transfer(transfer_attrs)
    Transfer.transaction do
      attrs = transfer_attrs.slice(:key, :category, :description)
      transfer_attrs[:operations].each do |op_pair|
        currency = Currency.find(op_pair[:currency])

        debit_op = op_pair[:account_src].merge(debit: op_pair[:amount], credit: 0.0, currency: currency)
        credit_op = op_pair[:account_dst].merge(credit: op_pair[:amount], debit: 0.0, currency: currency)

        [debit_op, credit_op].each do |op|
          klass = ::Operations.klass_for(code: op[:code])

          uid = op.delete(:uid)
          op.merge!(member: Member.find_by!(uid: uid)) if uid.present?

          type = ::Operations::Account.find_by(code: op[:code]).type
          type_plural = type.pluralize
          if attrs[type_plural].present?
            attrs[type_plural].push(klass.new(op))
          else
            attrs[type_plural] = [klass.new(op)]
          end
        end
      end

      Transfer.create!(attrs)
    end
  end

  before(:each) do
    Jobs::Cron::StatsMemberPnl.stubs(:exclude_roles).returns(['maker'])
  end

  context 'conversion_market' do
    it 'when there is no market' do
      expect do
        Jobs::Cron::StatsMemberPnl.conversion_market('test1', 'btc')
      end.to raise_error('There is no market test1/btc')
    end

    it 'when market exists' do
      market = Market.first
      expect(Jobs::Cron::StatsMemberPnl.conversion_market(market.base_unit, market.quote_unit)).to eq market.id
    end
  end

  context 'price_at' do
    after { delete_measurments('trades') }

    let!(:coin_deposit) { create(:deposit, :deposit_btc) }
    let!(:liability) { create(:liability, member: member, credit: 0.4, reference_type: 'Deposit', reference_id: coin_deposit.id) }

    it 'when there is no trades' do
      market = Market.find_by(base_unit: 'btc', quote_unit: 'usd')
      expect do
        Jobs::Cron::StatsMemberPnl.price_at(coin_deposit.currency_id, market.quote_unit, liability.created_at)
      end.to raise_error("There is no trades on market #{coin_deposit.currency_id}#{market.quote_unit}")
    end

    context 'when trade exist' do
      let(:trade) { create(:trade, :btceth, price: '5.0'.to_d, amount: '1.9'.to_d, total: '5.5'.to_d) }

      before do
        trade.write_to_influx
      end

      it 'return trade price' do
        res = Jobs::Cron::StatsMemberPnl.price_at(coin_deposit.currency_id, trade.market.quote_unit, trade.created_at + 3.hours)
        expect(res).to eq trade.price
      end

      it 'when pnl currency id equal to currency id' do
        res = Jobs::Cron::StatsMemberPnl.price_at(coin_deposit.currency_id, coin_deposit.currency_id, trade.created_at + 3.hours)
        expect(res).to eq 1.0
      end
    end
  end

  context 'process currency' do
    before(:each) do
      StatsMemberPnl.delete_all
    end

    context 'reference type withdraw' do
      before do
        [member, maker].each do |m|
          m.touch_accounts
          m.accounts.map { |a| a.update(balance: 500) }
        end
      end

      context 'creates one pnl' do
        let!(:coin_withdraw) { create(:btc_withdraw, sum: 0.3.to_d, amount: 0.2.to_d, aasm_state: 'succeed', member: member) }
        let!(:coin_withdraw_maker) { create(:btc_withdraw, sum: 0.3.to_d, amount: 0.2.to_d, aasm_state: 'succeed', member: maker) }
        let!(:pnl) { create(:stats_member_pnl) }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(123)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process() }.to change { StatsMemberPnl.count }.by(1)

          expect(StatsMemberPnl.last.member_id).to eq coin_withdraw.member_id
          expect(StatsMemberPnl.last.currency_id).to eq coin_withdraw.currency_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.total_credit).to eq 0
          expect(StatsMemberPnl.last.total_debit).to eq coin_withdraw.amount
          expect(StatsMemberPnl.last.total_debit_value).to eq((coin_withdraw.amount + coin_withdraw.fee) * 123)
          expect(StatsMemberPnl.last.total_debit_fees).to eq coin_withdraw.fee
          expect(StatsMemberPnl.last.total_credit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_value).to eq 0
          expect(StatsMemberPnl.last.total_balance_value).to eq 0
          expect(StatsMemberPnl.last.average_balance_price).to eq 0
        end
      end

      context 'calculation on existing pnl' do
        let!(:coin_withdraw) { create(:btc_withdraw, amount: 0.2.to_d, aasm_state: 'succeed', member: member) }
        let!(:pnl) do
          create(:stats_member_pnl, currency_id: coin_withdraw.currency_id, pnl_currency_id: 'eth', total_debit: 0.1,
                             total_debit_fees: 0.01, total_debit_value: 0.3,
                             member_id: coin_withdraw.member_id)
        end
        let!(:liability) do
          create(:liability, id: 2, member_id: coin_withdraw.member_id, currency_id: coin_withdraw.currency_id,
                             debit: 0.3, reference_type: 'Withdraw', code: 212, reference_id: coin_withdraw.id)
        end

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(0)

          expect(StatsMemberPnl.last.member_id).to eq coin_withdraw.member_id
          expect(StatsMemberPnl.last.currency_id).to eq coin_withdraw.currency_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.total_credit).to eq 0
          expect(StatsMemberPnl.last.total_debit).to eq coin_withdraw.amount + pnl.total_debit
          expect(StatsMemberPnl.last.total_debit_value).to eq (coin_withdraw.amount + coin_withdraw.fee) * 1.0 + pnl.total_debit_value
          expect(StatsMemberPnl.last.total_debit_fees).to eq coin_withdraw.fee + pnl.total_debit_fees
          expect(StatsMemberPnl.last.total_credit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_value).to eq 0
          expect(StatsMemberPnl.last.total_balance_value).to eq 0
          expect(StatsMemberPnl.last.average_balance_price).to eq 0
        end
      end
    end

    context 'reference type adjustments' do
      context 'creates one pnl with positive adjustment' do
        let!(:member) { create(:member) }
        let!(:adjustment) { create(:adjustment, currency_id: 'btc', amount: 1.0, receiving_account_number: "btc-202-#{member.uid}") }
        let!(:adjustment_maker) { create(:adjustment, currency_id: 'btc', amount: 1.0, receiving_account_number: "btc-202-#{maker.uid}") }
        let(:btceth_price) { 100.0 }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(btceth_price)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
          adjustment.accept!(validator: member)
          adjustment_maker.accept!(validator: member)
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(1)
          expect(StatsMemberPnl.last.member_id).to eq member.id
          expect(StatsMemberPnl.last.currency_id).to eq adjustment.currency_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.total_credit).to eq adjustment.amount
          expect(StatsMemberPnl.last.total_debit).to eq 0
          expect(StatsMemberPnl.last.total_debit_value).to eq 0
          expect(StatsMemberPnl.last.total_debit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_value).to eq adjustment.amount * btceth_price
          expect(StatsMemberPnl.last.total_balance_value).to eq adjustment.amount * btceth_price
          expect(StatsMemberPnl.last.average_balance_price).to eq btceth_price
        end
      end

      context 'creates one pnl with positive and negative adjustments' do
        let(:member) { create(:member) }
        let(:adjustment) { create(:adjustment, currency_id: 'btc', amount: 1.0, receiving_account_number: "btc-202-#{member.uid}") }
        let(:btceth_price) { 100.0 }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(btceth_price)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
          adjustment.accept!(validator: member)
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(1)
          expect(StatsMemberPnl.last.member_id).to eq member.id
          expect(StatsMemberPnl.last.currency_id).to eq adjustment.currency_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.total_credit).to eq adjustment.amount
          expect(StatsMemberPnl.last.total_debit).to eq 0
          expect(StatsMemberPnl.last.total_debit_value).to eq 0
          expect(StatsMemberPnl.last.total_debit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_value).to eq adjustment.amount * btceth_price
          expect(StatsMemberPnl.last.total_balance_value).to eq adjustment.amount * btceth_price
          expect(StatsMemberPnl.last.average_balance_price).to eq btceth_price

          half = 1.to_d / 2
          adjustment2 = create(:adjustment, currency_id: 'btc', amount: -half, receiving_account_number: "btc-202-#{member.uid}")
          adjustment2.accept!(validator: member)

          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(0)

          expect(StatsMemberPnl.last.member_id).to eq member.id
          expect(StatsMemberPnl.last.currency_id).to eq adjustment.currency_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.total_credit).to eq adjustment.amount
          expect(StatsMemberPnl.last.total_debit).to eq 0.5
          expect(StatsMemberPnl.last.total_debit_value).to eq 50
          expect(StatsMemberPnl.last.total_debit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_value).to eq 1.0 * btceth_price
          expect(StatsMemberPnl.last.total_balance_value).to eq  half * btceth_price
          expect(StatsMemberPnl.last.average_balance_price).to eq btceth_price
        end
      end
    end

    context 'reference type deposit' do
      context 'creates one pnl' do
        let!(:coin_deposit) { create(:deposit, :deposit_btc) }
        let!(:coin_deposit_maker) { create(:deposit, :deposit_btc, member: maker) }
        let!(:pnl) { create(:stats_member_pnl) }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
          [coin_deposit, coin_deposit_maker].each do |d|
            d.accept!
            d.process!
          end
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(1)
          expect(StatsMemberPnl.last.member_id).to eq coin_deposit.member_id
          expect(StatsMemberPnl.last.currency_id).to eq coin_deposit.currency_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.total_credit).to eq coin_deposit.amount
          expect(StatsMemberPnl.last.total_debit).to eq 0
          expect(StatsMemberPnl.last.total_debit_value).to eq 0
          expect(StatsMemberPnl.last.total_debit_fees).to eq 0
          expect(StatsMemberPnl.last.total_credit_fees).to eq coin_deposit.fee
          expect(StatsMemberPnl.last.total_credit_value).to eq coin_deposit.amount * 1.0
          expect(StatsMemberPnl.last.total_balance_value).to eq coin_deposit.amount * 1.0
          expect(StatsMemberPnl.last.average_balance_price).to eq 1.0
        end
      end

      context 'creates several pnls' do
        let!(:coin_deposit) { create(:deposit, :deposit_btc) }
        let!(:fiat_deposit) { create(:deposit_usd, amount: 190.0) }
        let!(:pnl) { create(:stats_member_pnl) }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
          fiat_deposit.accept!
          coin_deposit.accept!
          coin_deposit.process!
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(2)

          stats_member_pnl_btc = StatsMemberPnl.find_by(currency_id: coin_deposit.currency_id, member: coin_deposit.member)
          stats_member_pnl_usd = StatsMemberPnl.find_by(currency_id: fiat_deposit.currency_id, member: fiat_deposit.member)
          expect(stats_member_pnl_btc.member_id).to eq coin_deposit.member_id
          expect(stats_member_pnl_btc.pnl_currency_id).to eq 'eth'
          expect(stats_member_pnl_btc.currency_id).to eq coin_deposit.currency_id
          expect(stats_member_pnl_btc.total_credit).to eq coin_deposit.amount
          expect(stats_member_pnl_btc.total_debit).to eq 0
          expect(stats_member_pnl_btc.total_debit_value).to eq 0
          expect(stats_member_pnl_btc.total_debit_fees).to eq 0
          expect(stats_member_pnl_btc.total_credit_fees).to eq coin_deposit.fee
          expect(stats_member_pnl_btc.total_credit_value).to eq coin_deposit.amount * 1.0
          expect(stats_member_pnl_btc.total_balance_value).to eq coin_deposit.amount * 1.0
          expect(stats_member_pnl_btc.average_balance_price).to eq 1.0

          expect(stats_member_pnl_usd.member_id).to eq fiat_deposit.member_id
          expect(stats_member_pnl_usd.pnl_currency_id).to eq 'eth'
          expect(stats_member_pnl_usd.currency_id).to eq fiat_deposit.currency_id
          expect(stats_member_pnl_usd.total_credit).to eq fiat_deposit.amount
          expect(stats_member_pnl_usd.total_debit).to eq 0
          expect(stats_member_pnl_usd.total_debit_value).to eq 0
          expect(stats_member_pnl_usd.total_debit_fees).to eq 0
          expect(stats_member_pnl_usd.total_credit_fees).to eq fiat_deposit.fee
          expect(stats_member_pnl_usd.total_credit_value).to eq fiat_deposit.amount * 1.0
          expect(stats_member_pnl_usd.total_balance_value).to eq fiat_deposit.amount * 1.0
          expect(stats_member_pnl_usd.average_balance_price).to eq 1.0
        end
      end

      context 'calculation on existing pnl' do
        let!(:coin_deposit) { create(:deposit, :deposit_btc, amount: '0.1'.to_d) }
        let!(:pnl) do
          create(:stats_member_pnl, currency_id: coin_deposit.currency_id, pnl_currency_id: 'eth', total_credit: 0.1,
                             total_credit_fees: '0.01'.to_d, total_credit_value: '0.3'.to_d, total_balance_value: '0.3'.to_d, member_id: coin_deposit.member_id)
        end

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0.to_f)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
          coin_deposit.accept!
          coin_deposit.process!
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(0)
          expect(StatsMemberPnl.last.member_id).to eq coin_deposit.member_id
          expect(StatsMemberPnl.last.pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.last.currency_id).to eq coin_deposit.currency_id
          expect(StatsMemberPnl.last.total_credit).to eq(coin_deposit.amount + pnl.total_credit)
          expect(StatsMemberPnl.last.total_credit_fees).to eq(coin_deposit.fee + pnl.total_credit_fees)
          expect(StatsMemberPnl.last.total_credit_value).to eq(pnl.total_credit_value + coin_deposit.amount * 1.0)
          expect(StatsMemberPnl.last.total_debit).to eq 0
          expect(StatsMemberPnl.last.total_debit_fees).to eq 0
          expect(StatsMemberPnl.last.total_debit_value).to eq 0
          expect(StatsMemberPnl.last.total_balance_value).to eq(pnl.total_credit_value + coin_deposit.amount * 1.0)
          expect(StatsMemberPnl.last.average_balance_price).to eq((pnl.total_balance_value + coin_deposit.amount * 1.0) / (coin_deposit.amount + pnl.total_credit - pnl.total_debit))
        end
      end
    end

    context 'reference type trade' do
      context 'calculation on existing pnl' do
        let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d) }
        let(:btceth_price) { 123 }

        let!(:pnl1) do
          create(:stats_member_pnl, pnl_currency_id: 'eth', currency_id: 'btc',
                             total_credit: 2.0, total_credit_fees: 0.2, total_credit_value: 11.0, total_balance_value: 11.0, total_debit: 0.02,
                             average_balance_price: 5.5,
                             total_debit_value: 1.0, member_id: trade.maker_order.member.id)
        end

        let!(:pnl2) do
          create(:stats_member_pnl, pnl_currency_id: 'eth', currency_id: 'usd',
                             total_credit: 0.1, total_credit_fees: 0.01, total_credit_value: 0.3, total_debit: 0.2,
                             total_debit_value: 10.0, member_id: trade.maker_order.member.id)
        end

        let!(:pnl3) do
          create(:stats_member_pnl, pnl_currency_id: 'eth', currency_id: 'usd',
                             total_credit: 0.4, total_credit_fees: 0.01, total_credit_value: 0.3, total_debit: 0.2,
                             average_balance_price: 0.1,
                             total_debit_value: 10.0, member_id: trade.taker_order.member.id)
        end

        let!(:pnl4) do
          create(:stats_member_pnl, pnl_currency_id: 'eth', currency_id: 'btc',
                             total_credit: 0.4, total_credit_fees: 0.01, total_credit_value: 0.3,
                             total_debit: 0.2, total_debit_value: 10.0, member_id: trade.taker_order.member.id)
        end

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(btceth_price)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(0)

          total_fees = trade.total * trade.order_fee(trade.maker_order)
          expect(StatsMemberPnl.all[0].member_id).to eq trade.maker_order.member.id
          expect(StatsMemberPnl.all[0].pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.all[0].currency_id).to eq pnl1.currency_id
          expect(StatsMemberPnl.all[0].total_credit).to eq pnl1.total_credit
          expect(StatsMemberPnl.all[0].total_credit_fees).to eq pnl1.total_credit_fees
          expect(StatsMemberPnl.all[0].total_debit).to eq trade.amount + pnl1.total_debit
          expect(StatsMemberPnl.all[0].total_debit_value).to eq pnl1.total_debit_value + trade.amount * btceth_price
          expect(StatsMemberPnl.all[0].total_credit_value).to eq pnl1.total_credit_value
          expect(StatsMemberPnl.all[0].total_balance_value).to eq(pnl1.total_balance_value - trade.amount * pnl1.average_balance_price)

          expect(StatsMemberPnl.all[1].member_id).to eq trade.maker_order.member.id
          expect(StatsMemberPnl.all[1].pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.all[1].currency_id).to eq pnl2.currency_id
          expect(StatsMemberPnl.all[1].total_credit).to eq trade.total - total_fees + pnl2.total_credit
          expect(StatsMemberPnl.all[1].total_credit_fees).to eq total_fees + + pnl2.total_credit_fees
          expect(StatsMemberPnl.all[1].total_debit).to eq pnl2.total_debit
          expect(StatsMemberPnl.all[1].total_debit_value).to eq pnl2.total_debit_value
          expect(StatsMemberPnl.all[1].total_credit_value).to eq pnl2.total_credit_value + (trade.total - total_fees) * btceth_price
          expect(StatsMemberPnl.all[1].total_balance_value).to eq pnl2.total_balance_value + (trade.total - total_fees) * btceth_price

          total_fees = trade.amount * trade.order_fee(trade.taker_order)
          expect(StatsMemberPnl.all[2].member_id).to eq trade.taker_order.member.id
          expect(StatsMemberPnl.all[2].pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.all[2].currency_id).to eq pnl3.currency_id
          expect(StatsMemberPnl.all[2].total_credit).to eq pnl3.total_credit
          expect(StatsMemberPnl.all[2].total_debit).to eq trade.total + pnl3.total_debit
          expect(StatsMemberPnl.all[2].total_debit_value).to eq trade.total * btceth_price + pnl3.total_debit_value
          expect(StatsMemberPnl.all[2].total_credit_fees).to eq pnl3.total_credit_fees
          expect(StatsMemberPnl.all[2].total_credit_value).to eq pnl3.total_credit_value
          expect(StatsMemberPnl.all[2].total_balance_value).to eq(0)

          expect(StatsMemberPnl.all[3].member_id).to eq trade.taker_order.member.id
          expect(StatsMemberPnl.all[3].pnl_currency_id).to eq 'eth'
          expect(StatsMemberPnl.all[3].currency_id).to eq pnl4.currency_id
          expect(StatsMemberPnl.all[3].total_credit).to eq trade.amount - total_fees + pnl4.total_credit
          expect(StatsMemberPnl.all[3].total_debit).to eq pnl4.total_debit
          expect(StatsMemberPnl.all[3].total_debit_value).to eq pnl4.total_debit_value
          expect(StatsMemberPnl.all[3].total_credit_fees).to eq total_fees + pnl4.total_credit_fees
          expect(StatsMemberPnl.all[3].total_credit_value).to eq pnl4.total_credit_value + (trade.amount - total_fees) * btceth_price
          expect(StatsMemberPnl.all[3].total_balance_value).to eq pnl4.total_balance_value + (trade.amount - total_fees) * btceth_price
        end
      end

      context 'creates pnls while executing 1 trade' do
        let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d) }
        let!(:pnl) { create(:stats_member_pnl) }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0.to_f)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(4)
          total_fees = trade.total * trade.order_fee(trade.maker_order)

          pnl1 = StatsMemberPnl.find_by(member_id: trade.maker_order.member.id, currency_id: trade.maker_order.income_currency.id, pnl_currency_id: 'eth')
          expect(pnl1.total_credit).to eq trade.total - total_fees
          expect(pnl1.total_debit).to eq 0
          expect(pnl1.total_debit_value).to eq 0
          expect(pnl1.total_credit_fees).to eq total_fees
          expect(pnl1.total_credit_value).to eq (trade.total - total_fees) * 1.0

          pnl2 = StatsMemberPnl.find_by(member_id: trade.maker_order.member.id, currency_id: trade.maker_order.outcome_currency.id, pnl_currency_id: 'eth')
          expect(pnl2.total_credit).to eq 0
          expect(pnl2.total_debit).to eq trade.amount
          expect(pnl2.total_debit_value).to eq trade.amount * 1.0
          expect(pnl2.total_credit_fees).to eq 0
          expect(pnl2.total_credit_value).to eq 0

          total_fees = trade.amount * trade.order_fee(trade.taker_order)
          pnl3 = StatsMemberPnl.find_by(member_id: trade.taker_order.member.id, currency_id: trade.taker_order.income_currency.id, pnl_currency_id: 'eth')
          expect(pnl3.total_credit).to eq trade.amount - total_fees
          expect(pnl3.total_debit).to eq 0
          expect(pnl3.total_debit_value).to eq 0
          expect(pnl3.total_credit_fees).to eq total_fees
          expect(pnl3.total_credit_value).to eq (trade.amount - total_fees) * 1.0

          pnl4 = StatsMemberPnl.find_by(member_id: trade.taker_order.member.id, currency_id: trade.taker_order.outcome_currency.id, pnl_currency_id: 'eth')
          expect(pnl4.total_credit).to eq 0
          expect(pnl4.total_debit).to eq trade.total
          expect(pnl4.total_debit_value).to eq trade.total * 1.0
          expect(pnl4.total_credit_fees).to eq 0
          expect(pnl4.total_credit_value).to eq 0
        end
      end

      context 'trades of makers should not create pnls' do
        let!(:trade) do
          create(
            :trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d,
            maker_order: create(:order_bid, :btceth, member: maker),
            taker_order: create(:order_ask, :btceth, member: maker)
          )

          create(
            :trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d,
            maker_order: create(:order_bid, :btceth, member: maker),
            taker_order: create(:order_ask, :btceth, member: maker2)
          )
        end
        let!(:pnl) { create(:stats_member_pnl) }

        before do
          Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0.to_f)
          Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('eth')])
        end

        it do
          expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(0)
        end
      end

    end
  end

  context 'process' do
    before do
      Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Market.first.quote_unit, Market.second.quote_unit].map{|id| Currency.find(id)})
    end

    context 'no liabilities' do
      it do
        Jobs::Cron::StatsMemberPnl.process
        expect(StatsMemberPnl.count).to eq 0
      end
    end

    context 'liability for reference type deposit' do
      let!(:coin_deposit) { create(:deposit, :deposit_btc) }
      let!(:pnl) { create(:stats_member_pnl) }

      before do
        Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0.to_f)
        coin_deposit.accept!
        coin_deposit.process!
        coin_deposit.dispatch!
      end

      it do
        expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(2)

        expect(StatsMemberPnl.second.member_id).to eq coin_deposit.member_id
        expect(StatsMemberPnl.second.currency_id).to eq coin_deposit.currency_id
        expect(StatsMemberPnl.second.pnl_currency_id).to eq Market.first.quote_unit
        expect(StatsMemberPnl.second.total_credit).to eq coin_deposit.amount
        expect(StatsMemberPnl.second.total_debit).to eq 0
        expect(StatsMemberPnl.second.total_debit_value).to eq 0
        expect(StatsMemberPnl.second.total_credit_fees).to eq coin_deposit.fee
        expect(StatsMemberPnl.second.total_debit_fees).to eq 0
        expect(StatsMemberPnl.second.total_credit_value).to eq coin_deposit.amount * 1.0

        expect(StatsMemberPnl.last.member_id).to eq coin_deposit.member_id
        expect(StatsMemberPnl.last.currency_id).to eq coin_deposit.currency_id
        expect(StatsMemberPnl.last.pnl_currency_id).to eq Market.second.quote_unit
        expect(StatsMemberPnl.last.total_credit).to eq coin_deposit.amount
        expect(StatsMemberPnl.last.total_debit).to eq 0
        expect(StatsMemberPnl.last.total_debit_value).to eq 0
        expect(StatsMemberPnl.last.total_credit_fees).to eq coin_deposit.fee
        expect(StatsMemberPnl.last.total_debit_fees).to eq 0
        expect(StatsMemberPnl.last.total_credit_value).to eq coin_deposit.amount * 1.0
      end
    end

    context 'liability for reference type deposit (not yet collected)' do
      let!(:coin_deposit) { create(:deposit, :deposit_btc) }
      let!(:pnl) { create(:stats_member_pnl) }

      before do
        Jobs::Cron::StatsMemberPnl.stubs(:price_at).returns(1.0.to_f)
        coin_deposit.accept!
        coin_deposit.process!
      end

      it do
        expect { Jobs::Cron::StatsMemberPnl.process }.to change { StatsMemberPnl.count }.by(2)
      end
    end
  end

  context 'scenario1_internal_sell' do
    before do
      Jobs::Cron::StatsMemberPnl.stubs(:pnl_currencies).returns([Currency.find('usd')])
    end

    def scenario1_internal_sell_with_partial_refund(msrc, mdst)
      key = (Time.now.to_f * 1000).to_i
      create(:deposit_usd, member: mdst, amount: 100).accept!
      d = create(:deposit_btc, member: msrc, amount: 0.09)
      d.accept!
      d.process!
      d.dispatch!

      transfers_attr = [
        {
          key: key,
          category: Transfer::CATEGORIES_MAPPING[:purchases],
          operations: [
            {
              currency: :usd,
              amount: 100,
              account_src: {
                code: 201,
                uid: mdst.uid
              },
              account_dst: {
                code: 211,
                uid: mdst.uid
              }
            }
          ]
        },
        {
          key: key + 1,
          category: Transfer::CATEGORIES_MAPPING[:purchases],
          operations: [
            {
              # Refund (unlock) user 10 usd
              currency: :usd,
              amount: 10,
              account_src: {
                code: 211,
                uid: mdst.uid
              },
              account_dst: {
                code: 201,
                uid: mdst.uid
              }
            },
            {
              # Transfer 89 usd from user to the platform
              currency: :usd,
              amount: 89,
              account_src: {
                code: 211,
                uid: mdst.uid
              },
              account_dst: {
                code: 201,
                uid: msrc.uid
              }
            },
            {
              # Transfer 1 usd from user to the platform fees
              currency: :usd,
              amount: 1,
              account_src: {
                code: 211,
                uid: mdst.uid
              },
              account_dst: {
                code: 301,
                uid: mdst.uid
              }
            },
            {
              # Transfer 0.09 btc from the platform to the user
              currency: :btc,
              amount: 0.09,
              account_src: {
                code: 202,
                uid: msrc.uid
              },
              account_dst: {
                code: 202,
                uid: mdst.uid
              }
            }
          ]
        }
      ]

      transfers_attr.each do |transfer_attrs|
        create_transfer(transfer_attrs)
      end
    end

    it 'excludes makers' do
      scenario1_internal_sell_with_partial_refund(maker2, maker)
      Jobs::Cron::StatsMemberPnl.process
      expect(StatsMemberPnl.count).to eq(0)
    end

    it do
      scenario1_internal_sell_with_partial_refund(member_platform, member)
      Jobs::Cron::StatsMemberPnl.stubs(:price_at).with('usd', 'usd', anything).returns(1)
      Jobs::Cron::StatsMemberPnl.stubs(:price_at).with('btc', 'usd', anything).returns(10_000)
      Jobs::Cron::StatsMemberPnl.process
      expect(StatsMemberPnl.count).to eq(4)

      musd = StatsMemberPnl.find_by(member_id: member.id, pnl_currency_id: 'usd', currency_id: 'usd')
      expect(musd.total_credit).to eq(100)
      expect(musd.total_credit_fees).to eq(0)
      expect(musd.total_debit_fees).to eq(1)
      expect(musd.total_debit).to eq(89)
      expect(musd.total_credit_value).to eq(100)
      expect(musd.total_debit_value).to eq(89)
      expect(musd.total_balance_value).to eq(10)
      expect(musd.average_balance_price).to eq(1)

      mbtc = StatsMemberPnl.find_by(member_id: member.id, pnl_currency_id: 'usd', currency_id: 'btc')
      expect(mbtc.total_credit).to eq(0.09)
      expect(mbtc.total_credit_fees).to eq(0)
      expect(mbtc.total_debit_fees).to eq(0)
      expect(mbtc.total_debit).to eq(0)
      expect(mbtc.total_credit_value).to eq(90)
      expect(mbtc.total_debit_value).to eq(0)
      expect(mbtc.total_balance_value).to eq(90)
      expect(mbtc.average_balance_price).to eq(1000)
    end

    def scenario2_internal_sell
      key = (Time.now.to_f * 1000).to_i
      create(:deposit_usd, member: member, amount: 100).accept!
      d = create(:deposit_btc, member: member_platform, amount: 0.09)
      d.accept!
      d.process!
      d.dispatch!

      transfers_attr = [
        {
          key: key,
          category: Transfer::CATEGORIES_MAPPING[:purchases],
          operations: [
            {
              currency: :usd,
              amount: 100,
              account_src: {
                code: 201,
                uid: member.uid
              },
              account_dst: {
                code: 211,
                uid: member.uid
              }
            }
          ]
        },
        {
          key: key + 1,
          category: Transfer::CATEGORIES_MAPPING[:purchases],
          operations: [
            {
              # Transfer 99 usd from user to the platform
              currency: :usd,
              amount: 99,
              account_src: {
                code: 211,
                uid: member.uid
              },
              account_dst: {
                code: 201,
                uid: member_platform.uid
              }
            },
            {
              # Transfer 1 usd from user to the platform fees
              currency: :usd,
              amount: 1,
              account_src: {
                code: 211,
                uid: member.uid
              },
              account_dst: {
                code: 301,
                uid: member.uid
              }
            },
            {
              # Transfer 0.09 btc from the platform to the user
              currency: :btc,
              amount: 0.09,
              account_src: {
                code: 202,
                uid: member_platform.uid
              },
              account_dst: {
                code: 202,
                uid: member.uid
              }
            }
          ]
        }
      ]

      transfers_attr.each do |transfer_attrs|
        create_transfer(transfer_attrs)
      end
    end

    it do
      scenario2_internal_sell
      Jobs::Cron::StatsMemberPnl.stubs(:price_at).with('usd', 'usd', anything).returns(1)
      Jobs::Cron::StatsMemberPnl.stubs(:price_at).with('btc', 'usd', anything).returns(10_000)
      Jobs::Cron::StatsMemberPnl.process

      expect(StatsMemberPnl.count).to eq(4)
      musd = StatsMemberPnl.find_by(member_id: member.id, pnl_currency_id: 'usd', currency_id: 'usd')
      expect(musd.total_credit).to eq(100)
      expect(musd.total_credit_fees).to eq(0)
      expect(musd.total_debit_fees).to eq(1)
      expect(musd.total_debit).to eq(99)
      expect(musd.total_credit_value).to eq(100)
      expect(musd.total_debit_value).to eq(99)
      expect(musd.total_balance_value).to eq(0)
      expect(musd.average_balance_price).to eq(1)

      mbtc = StatsMemberPnl.find_by(member_id: member.id, pnl_currency_id: 'usd', currency_id: 'btc')
      expect(mbtc.total_credit).to eq(0.09)
      expect(mbtc.total_credit_fees).to eq(0)
      expect(mbtc.total_debit_fees).to eq(0)
      expect(mbtc.total_debit).to eq(0)
      expect(mbtc.total_credit_value).to be_within(0.0001).of(100)
      expect(mbtc.total_debit_value).to eq(0)
      expect(mbtc.total_balance_value).to be_within(0.0001).of(100)
      expect(mbtc.average_balance_price).to be_within(0.01).of(1111.11)
    end
  end

  context 'parse_conversion_paths' do
    it do
      expect(Jobs::Cron::StatsMemberPnl.parse_conversion_paths(nil)).to eq({})
      expect(Jobs::Cron::StatsMemberPnl.parse_conversion_paths('')).to eq({})
      expect(Jobs::Cron::StatsMemberPnl.parse_conversion_paths('usdt/abc:usdt/usd,usd/abc')).to eq(
        'usdt/abc' => [['usdt', 'usd', false], ['usd', 'abc', false]],
      )
      expect(Jobs::Cron::StatsMemberPnl.parse_conversion_paths('usdt/abc:usdt/usd,usd/abc;usdt/def:usdt/usd,def/abc,abc/usd')).to eq(
        'usdt/abc' => [['usdt', 'usd', false], ['usd', 'abc', false]],
        'usdt/def' => [['usdt', 'usd', false], ['def', 'abc', false], ['abc', 'usd', false]]
      )
      expect(Jobs::Cron::StatsMemberPnl.parse_conversion_paths('usdt/abc:_usd/usdt,usd/abc')).to eq(
        'usdt/abc' => [['usd', 'usdt', true], ['usd', 'abc', false]],
      )
      expect { Jobs::Cron::StatsMemberPnl.parse_conversion_paths('usdt/abc,abc/usd') }.to raise_error(StandardError)
      expect { Jobs::Cron::StatsMemberPnl.parse_conversion_paths(':usdt/abc,abc/usd') }.to raise_error(StandardError)
      expect { Jobs::Cron::StatsMemberPnl.parse_conversion_paths('usdtabc:usdt/usd,usd/abc') }.to raise_error(StandardError)
      expect { Jobs::Cron::StatsMemberPnl.parse_conversion_paths('usdt/abc:usdtusd,usdabc') }.to raise_error(StandardError)
    end
  end

  context 'conversion path' do
    before(:each) do
      Trade.stubs(:nearest_trade_from_influx).with('btceth', anything).returns(price: 0.95)
      Trade.stubs(:nearest_trade_from_influx).with('btcusd', anything).returns(price: 10_000)
    end

    it do
      expect(Jobs::Cron::StatsMemberPnl.price_at('btc', 'eth', 0)).to eq(0.95)
      expect(Jobs::Cron::StatsMemberPnl.price_at('btc', 'usd', 0)).to eq(10_000)
    end

    it 'uses direct markets prices' do
      Jobs::Cron::StatsMemberPnl.stubs(:conversion_paths).returns(
        'btc/abc' => [['btc', 'eth', false], ['btc', 'usd', false]]
      )
      expect(Jobs::Cron::StatsMemberPnl.price_at('btc', 'abc', 0)).to eq(9500)
    end

    it 'reverses a market price' do
      Jobs::Cron::StatsMemberPnl.stubs(:conversion_paths).returns(
        'btc/abc' => [['btc', 'eth', true], ['btc', 'usd', false]]
      )
      expect(Jobs::Cron::StatsMemberPnl.price_at('btc', 'abc', 0)).to be_within(0.0001).of(10526.3157)
    end
  end
end
