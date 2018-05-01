module APIv2
  class Fees < Grape::API
    Fee         = Struct.new(:type, :value)
    WithdrawFee = Struct.new(:currency, :type, :fee)
    DepositFee  = Struct.new(:currency, :type, :fee)
    TradingFee  = Struct.new(:market, :ask_fee, :bid_fee)

    desc 'Returns withdraw fees for currencies.'
    get '/fees/withdraw' do
      withdraw_fees = Currency.visible.map do |c|
        fee = Fee.new(:fixed, c.withdraw_fee)
        WithdrawFee.new(c.code, c.type, fee)
      end
      present withdraw_fees
    end

    desc 'Returns deposit fees for currencies.'
    get '/fees/deposit' do
      deposit_fees = Currency.visible.map do |c|
        fee = Fee.new(:fixed, c.deposit_fee)
        DepositFee.new(c.code, c.type, fee)
      end
      present deposit_fees
    end

    desc 'Returns trading fees for markets.'
    get '/fees/trading' do
      trading_fees = Market.visible.map do |m|
        ask_fee = Fee.new(:relative, m.ask_fee)
        bid_fee = Fee.new(:relative, m.bid_fee)
        TradingFee.new(m.id, ask_fee, bid_fee)
      end
      present trading_fees
    end
  end
end
